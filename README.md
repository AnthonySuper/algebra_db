# AlgebraDB

This is a database library for Ruby based on *relational expressions*.
Most other database libraries, like the excellent [sequel](https://github.com/jeremyevans/sequel) or [activerecord](https://github.com/rails/rails/tree/master/activerecord) are based on some idea of a *scoped dataset*, which is essentially an object that you can chain methods on to do further filtering, ordering, or what have you.
AlgebraDB is instead based on a sort of *typed query builder*.
Your queries return arrays of structs, custom-made for whatever query you're doing.
This encourages us to use the full functionality of our database, resulting in faster and more correct queries.

An example is probably illustrative...

## Example

Let's say I have two tables.
One is a `users` table, defined like this:

```sql
CREATE TABLE users(
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL
);

-- Probably some sort of "What did the user do" thing.
CREATE TABLE user_audits(
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  scoped_granted TEXT[] NOT NULL,
  values_changes JSONB DEFAULT '{}'::jsonb
);
```

Now, these two tables are relatively nice to work with.
But, what if I wanted to run a query that gave me all the audit logs performed under similar scopes, and what users performed those?
This is already a bit of an annoying query, but it gets worse if I want to include the users' full names as well.

With AlgebraDB, we would define some classes like this:

```ruby
##
# Basic user table
class User < AlgebraDB::Table
  self.table_name = :users

  column :id, :Integer
  column :first_name, :Text
  column :last_name, :Text

end

##
# Audit log for users
class UserAudit < AlgebraDB::Table
  self.table_name = :user_audits

  column :id, :Integer
  column :user_id, :Integer
  column :scopes_granted, AlgebraDB::Value::Array::Text
  column :changes, AlgebraDB::Value::JSONB
end
```

We could then run a query like this:

```ruby
query = AlgebraDB::Statement::Select.run_syntax do
  parent_audits = all(UserAudit)
  parent_audit_users = joins(User) do |user|
    user.id.eq(parent_audits.user_id)
  end
  child_audits = joins(UserAudit) do |other_audit|
    other_audit.scopes_granted.overlaps(parent_audits.scopes_granted).and(
      other_audits.id.neq(parent_audits.id)
    )
  end
  child_audit_users = joins(User) do |user|
    user.id.eq(child_audits.user_id)
  end
  select(
    parent_audit_id: parent_audits.id,
    parent_audit_user: parent_audit_users.first_name.append(raw_param(' ')).append(parent_audit_users.last_name),
    child_audit_id: child_audits.id,
    child_audit_user: child_audit_users.first_name.append(raw_param(' ')).append(child_audit_users.last_name)
  )
end
```

This, of course, is not the best code. 
We're doing a lot of repetition.
However, since AlgebraDB operates on *tables* instead of *records*, we can define some cleanup easily:


```ruby
##
# Basic user table
class User < AlgebraDB::Table
  self.table_name = :users

  column :id, :Integer
  column :first_name, :Text
  column :last_name, :Text

  ##
  # Instances are a *table in a query*, so this works!
  def full_name
    first_name.concat(AlgebraDB::Build.param(' ')).concat(last_name)
  end
end

##
# Audit log for users
class UserAudit < AlgebraDB::Table
  self.table_name = :user_audits

  column :id, :Integer
  column :user_id, :Integer
  column :scopes_granted, AlgebraDB::Value::Array::Text
  column :changes, AlgebraDB::Value::JSONB

  relationship :user, User do |user|
    user.id.eq(user_id)
  end

  relationship :similar_audits, UserAudit do |other_audit|
    other_audit.scopes_granted.overlaps(scopes_granted).and(
      other_audit.id.neq(id)
    )
  end
end
```

Now we only need to write:

```ruby
AlgebraDB::Statement::Select.run_syntax do
  parent_audits = all(UserAudit)
  parent_audit_users = join_relationship(parent_audits.user)
  child_audits = join_relationship(parent_audits.similar_audits)
  child_audit_users = join_relationship(child_audits.user)
  select(
    parent_audit_id: parent_audits.id,
    parent_audit_user: parent_audit_users.full_name,
    child_audit_id: child_audits.id,
    child_audit_user: child_audit_users.full_name
  )
end
```

Notice a few things we did here that make this moderately magic:

1. We joined in the same table multiple times very, very easily.
   These tables have different aliases in the query, so if we wanted only child audits by a user with a name like "bob", we could have just added a `where(child_audit_users.full_name.ilike(raw_param('Bob')))`
2. All of the user-supplied data happens via postgres parameters.
   We're not putting raw SQL strings *anywhere*: even the space in the `full_name` method is parameterized!
3. We wrote an ad-hoc aliased select list, which will be converted at runtime to ruby `Struct` instances with the right keys.
   That means we can sort those records, use them as keys in a hash, or do whatever we want, easily.

In the future this will make way for powerful aggregation functionality.
Postgres already has `ARRAY_AGG` and `JSONB_AGG`.
Instead of making multiple queries to do eager-loading, or making one big query and then performing reassociation yourself, you'll be able to let the database (which is a hell of a lot faster than Ruby) do it for you!

### Inserts

We provide more fully-fledged insert functionality as well.
For example, you wish to simply insert some hashes, you can:

```ruby
AlgebraDB::Statement::Insert.insert_hash(
  User,
  [
    { first_name: 'Bob', last_name: 'Smith' },
    { first_name: 'Bob', last_name: 'Warwick' }
  ]
)
```

However, you can also insert from a *select*.
This can be quite handy:

```ruby
AlgebraDB::Statement::Insert.run_syntax do
  into(UserAudit, %i[user_id])
  select do
    u = all(User)
    select(user_id: u.id)
  end
end
```

This generates SQL like:

```ruby
INSERT INTO user_audits(user_id)
SELECT users.id AS user_id FROM users
```

This is much faster than doing a round-trip through ruby to get the insert!

### Updates

Updates have the full functionality of actual SQL updates.
That is, you can do a simple update, like this:

```ruby
AlgebraDB::Statement::Update.run_syntax do
  u = table(User)
  set(:first_name, param('Mega Anthony'))
  where(u.first_name.eq(param('Anthony')))
  returning(:id, :first_name)
end
```

This generates, roughly:

```sql
UPDATE users
SET first_name = 'Mega Anthony'
WHERE first_name = 'Anthony'
RETURNING id, first_name
```

(Note: in the actual code, parameterized queries are of course used.)

You can also do a more complex one, like this:

```ruby
AlgebraDB::Statement::Update.run_syntax do
  u = table(User)
  set(:first_name, u.first_name.append(param(' is dope')))
  returning(:id, :first_name)
end
```

This generates:

```sql
UPDATE users
SET first_name = first_name || ' is dope'
RETURNING id, first_name
```

This uses an *expression* in the update statement, something rather annoying to do with other Ruby database libraries.
It, too, winds up being much, much faster!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'algebra_db'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install algebra_db

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/algebra_db.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
