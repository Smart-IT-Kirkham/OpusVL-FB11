# OpusVL-FB11

> Business and Social Application Framework

**Flexibase** is a set of pre-built software components that can be assembled to deliver business functions as part of a business application.

It is an extension of the Catalyst MVC framwework with additional features suitable for building business applications including:

- Responsive design user interface
- Automatically generated menus
- Applicaiton composition
- Audit trail
- Modular components
- Role-based access control
- LDAP integration
- Website CMS
- Odoo ERP ORM module (accounting, stock etc)

For more information, visit http://flexibase.io

## 13th March 2019: FB11 v0.041 has been released

This is probably one of the biggest updates to FB11 to date, but we still don't think it's quite enough to call FB11 version 1.

The main thing missing before we call it version 1 is tests. Currently, FB11 has very few tests - only those written recently, to test the Hive. We would like to at least have smoke tests to ensure that

* The database can be deployed
* Users can be created
* Those users can log in

We would also probably want to bring more things into core. Currently the audit trail and sysparams modules are core FB11, so we would also want to add smoke tests for those features before v1 is made.

Once we get to v1, we're going to start on the tried-and-tested integer number scheme again. This, despite the fact that FB11 is technically open-source; that's because we use FB11 to such a great degree that it is more valuable to us for FB11 to use our internal versioning scheme than to support the 3 branches implied by semver.

Secondarily, the "major" version of FB11 is, well, 11. So currently we're really on Flexibase 11.0.041 and soon we'll be releasing Flexibase 11.1.

If you're interested in the changes made in FB11 since the last released version, feel free to gawp at the length of this file.

https://github.com/OpusVL/OpusVL-FB11/blob/master/Changes 

Al.

# Copyright and License

Copyright (C) 2016-2018 OpusVL

https://opusvl.com 
community@opusvl.com

This library is free software; you can redistribute it and/or modify it under the terms of either;
a) the GNU General Public License as published by the Free Software Foundation; either version 1, or (at your option) any later version, or
b) the "Artistic License".
