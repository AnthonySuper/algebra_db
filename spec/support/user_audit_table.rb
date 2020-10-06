##
# Fake test table.
class UserAuditTable < AlgebraDB::Table
  self.table_name = :user_audits

  column :id, :Integer
  column :user_id, :Integer
  column :scopes_granted, AlgebraDB::Value::Array::Text
  column :changes, :JSONB
end
