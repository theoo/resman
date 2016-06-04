
json.array! @residents do |r|
  json.id    r.id
  json.label r.full_name
  json.value r.full_name
end