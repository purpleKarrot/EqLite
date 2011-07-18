##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

set(Equalizer_INCLUDE_DIRS "/usr/include")

include(Equalizer.cmake)

set(EQUALIZER_Collage_LIBRARY Collage)
set(EQUALIZER_Client_LIBRARY Equalizer)
set(EQUALIZER_Admin_LIBRARY EqualizerAdmin)
set(EQUALIZER_Server_LIBRARY EqualizerServer)

set(EQUALIZER_LIBRARIES
  ${EQUALIZER_Collage_LIBRARY}
  ${EQUALIZER_Client_LIBRARY}
  ${EQUALIZER_Admin_LIBRARY}
  ${EQUALIZER_Server_LIBRARY}
  )
