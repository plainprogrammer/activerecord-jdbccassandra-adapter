# jdbc-cassandra

Based on the official JDBC driver for Cassandra.

It is a native Java driver that converts JDBC (Java Database Connectivity)
calls into the network protocol used by the MySQL database.

For more information see https://code.google.com/a/apache-extras.org/p/cassandra-jdbc/

## Usage

To make the driver accessible to JDBC and ActiveRecord code running in JRuby :

    require 'jdbc/cassandra'
    Jdbc::Cassandra.load_driver

## Copyright

Copyright (c) 2013 [James Thompson](https://github.com/plainprogrammer).

This open source software is provided under the MIT license, see *LICENSE.txt*.
