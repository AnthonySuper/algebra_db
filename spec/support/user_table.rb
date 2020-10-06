##
# Spec-only class used to make testing easier.
class UserTable < AlgebraDB::Table
  self.table_name = :users

  column :id, :Integer
  column :first_name, :Text
  column :last_name, :Text
end
