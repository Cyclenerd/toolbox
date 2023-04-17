
# toset: Pass a list value to toset to convert it to a set,
#        which will remove any duplicate elements and discard the ordering of the elements.
locals {
  bla = toset([
    "eins",
    "eins", # duplicate
    "zwei",
    "drei"
  ])
}

resource "local_file" "foo" {
  for_each = local.bla
  content = (
    each.value == "drei"
    ? "3"
    : upper(each.value)
  )
  filename = "${path.module}/${each.value}.value"
}

resource "local_file" "foo2" {
  for_each = {
    for key, value in local.bla :
    key => upper(key)
    if key == "eins"
  }
  # Loop, without extra newline (~ strip marker).
  content  = <<EOF
%{~for zahl in local.bla}
${zahl}
%{~endfor}
EOF
  filename = "${path.module}/${each.key}.key"
}