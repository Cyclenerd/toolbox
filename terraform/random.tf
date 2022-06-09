###############################################################################
# RANDOM
###############################################################################

# Generate random int
# ${random_integer.bla.id}
resource "random_integer" "bla" {
  min = 100000
  max = 999999
}

# Generate random id
# ${random_id.bla.hex}
# HEX example: bac02795b8490bf0
#              byte lenght * 2
resource "random_id" "bla" {
  byte_length = 8
}

# Generate random UUID for bucket
# ${random_uuid.bla.id}"
resource "random_uuid" "bla" {
}