require "mkmf"

dir_config("em_udns")
have_library("udns")  # == -ludns

create_makefile("em_udns")
