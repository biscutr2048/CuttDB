
CuttDB

created by @biscutr2048

a sqlite3 access automation model

# top requirements
![CuttDB requirements](cuttdb_feature_0607.png)

## json friendly
    * sqlite 3.38 higher
        ** iOS 2020
        ** macos 11

## processing（2025-06-04）


# requirements
VER:0.1

# create

    ## auto.get create sql    ➡️
    ## auto.create when need, if not exists    💯
    ## auto.create sub-table when listing    ➡️
    ## auto.index local, with listing    ➡️

# select

    ## mech. load response local.offline    1️⃣
    ## auto.select object to sql    1️⃣
    ## auto.select obj.list to sql paged    ➡️
    ## auto.select by biz key and list    🈳

# insert

    ## mech.save response    1️⃣
    ## op.save object to insert sql    💯
    ## op.save obj.list to insert sql    ➡️

# update

    ## op.save object to update sql    💯
    ## op.save obj.list to update sql    ➡️

# delete

    ## op.delete update to aged    🈳

# PARADIGM

    ## BIZ-DEF, CRUD by occasion, testing    🌰

# drop

    ## drop missing, testing, debug-if    ➡️

# align

    ## upgrade dest-table from src-table    ➡️

# mechanism

    ## pair table to req, obj_list, paged    💯
    ## json object gt 3.38    🈶
    ## vector table    🈳


---


## for Users

- manage SQLite table structs
- need auto response process
- gen SQL developers
- recover response
- deal with listing and properties, even sub-table automatically.


---


## MIT LICENSE

Copyright (c) 2025 BISCUTR

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
