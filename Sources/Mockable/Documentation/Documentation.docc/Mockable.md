# ``Mockable``

A macro driven testing framework that provides automatic mock implementations for your protocols. It offers an intuitive declarative syntax that simplifies the process of mocking services in unit tests. 

## Overview

**Mockable** utilizes the new Swift macro system to generate code that eliminates the need for external dependencies like Sourcery.
It has a declarative API that enables you to rapidly specify return values and verify invocations in a readable format.


Associated types, generic functions, where clauses and constrained generic arguments are all supported.
The generated mock implementations can be excluded from release builds using a built in compile condition.

## Topics

### Guides

- <doc:Installation>
- <doc:Configuration>
- <doc:Usage>
