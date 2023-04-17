locals {
  a = {
    "1" = "eins",
    "2" = "zwei",
  }
  b = {
    "2" = "zwei aus B",
    "3" = "drei aus B"
  }
  # merge takes an arbitrary number of maps or objects,
  # and returns a single map or object that contains a merged set of elements from all arguments.
  c = merge(local.a, local.b)
}

resource "local_file" "foo" {
  # Loop, without extra newline (~ strip marker).
  content  = <<EOF
%{~for zahl in local.c}
${zahl}
%{~endfor}
EOF
  filename = "${path.module}/merge.txt"
}