# System Bus Design Project

## Project Overview

This project implements a Bus system with digital system design techniques, developed as part of the Advanced Digital Systems course (EN4021) at the University of Moratuwa. When designing we used AMBA bus specifications as a template and designed our own simple protocol and a bus inter-connect to implement it.

## Specifications

## Approach

To design and implement a system bus under given specifications, we used bottom up approach of digital system design. Initially started with simple master, simple slave and sucessful communications between them. Then extended the system to support multiple slaves(three slaves): single master multiple slaves system (SMMS). After testing SMMS system, we extended it further to a multiple master (two masters)- multiple slave (three slaves) system (MMMS). After sucessfully simulating MMMS system we replaced one slave with split supported slave and extended our arbiter to support split transactions. Then one master and one slave was replaced by a master bridge and a slave bridge in order to support for inter bus communications.Using bus bridges we connected two copies of our MMMS bus (simple_bridge_v2) and sucessful simulations of communications between buses were done.