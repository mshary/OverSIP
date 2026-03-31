require "mkmf"

dir_config("em_udns")
have_library("udns")  # == -ludns

create_makefile("oversip/em_udns")
