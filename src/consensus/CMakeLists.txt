# Copyright (c) 2024, The Xwift Project
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met (see LICENSE file).

set(consensus_sources
  consensus_engine.cpp)

set(consensus_headers
  consensus_engine.h)

monero_private_headers(consensus
  ${consensus_headers})

monero_add_library(consensus
  ${consensus_sources}
  ${consensus_headers})

target_link_libraries(consensus
  PUBLIC
    epee
    cncrypto
    cryptonote_core)
