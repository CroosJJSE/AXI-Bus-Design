# System Bus Design Project

## Project Overview

This project implements a sophisticated Serial Bus system with advanced digital system design techniques, developed as part of the Advanced Digital Systems course (EN4021) at the University of Moratuwa.

## Specifications

## Approach

To design and implement a system bus under given specifications, we used bottom up approach of digital system design. Initially started with simple master, simple slave and sucessful communications between them. Then extended the system to support multiple slaves(three slaves): single master multiple slaves system (SMMS). After testing SMMS system, we extended it further to a multiple master (two masters)- multiple slave (three slaves) system (MMMS). After sucessfully simulating MMMS system we replaced one slave with split supported slave and extended our arbiter to support split transactions. Then one master and one slave was replaced by a master bridge and a slave bridge in order to support for inter bus communications.