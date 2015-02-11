#define BOOST_TEST_DYN_LINK
#define BOOST_TEST_MODULE Hello
#include <boost/test/unit_test.hpp>
#include "add.h"

BOOST_AUTO_TEST_CASE(universeInOrder)
{
    BOOST_CHECK_MESSAGE(add(2, 2) == 5, "The universe is *not* in order.");
}

