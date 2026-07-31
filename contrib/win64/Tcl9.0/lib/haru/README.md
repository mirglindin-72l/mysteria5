haru - PDF library
================
`haru` Tcl bindings for [libharu](http://libharu.org/).   

Motivation :
-------------------------

Be able to integrate a 3D file in a PDF, unlike this package [pdf4tcl](https://sourceforge.net/projects/pdf4tcl/).   

> [!NOTE]  
> Another similar project had already written this in Tcl, without _dependencies_.   
You can find [here](http://reddog.s35.xrea.com/wiki/tclhpdf.html), functions are the same, but it does not include the latest `libharu` updates.  

Requirements :
-------------------------
- [Tcl](https://www.tcl.tk/) 8.6 or higher
- [tcl-cffi](https://cffi.magicsplat.com) >= 2.0
- [libharu](http://libharu.org/) >= v2.4.3

Examples :
-------------------------
```tcl
package require haru

set page_title "haru Tcl bindings for libharu..."

# init haru pdf...
set pdf [HPDF_New]

# adds a new page object.
set page [HPDF_AddPage $pdf]

# page format
HPDF_Page_SetSize $page HPDF_PAGE_SIZE_A4 HPDF_PAGE_PORTRAIT

# page size
set height [HPDF_Page_GetHeight $page]
set width  [HPDF_Page_GetWidth $page]

# set font and size
set def_font [HPDF_GetFont $pdf "Helvetica" ""]
HPDF_Page_SetFontAndSize $page $def_font 24

# get text size
set tw [HPDF_Page_TextWidth $page [haru::hpdf_encode $page_title]]

# write text
HPDF_Page_BeginText $page
HPDF_Page_TextOut $page [expr {($width - $tw) / 2}] [expr {$height - 50}] [haru::hpdf_encode $page_title]
HPDF_Page_EndText $page

# save the document to a file
HPDF_SaveToFile $pdf haru.pdf

# free... (because we are FREE!)
HPDF_Free $pdf
```
Some characters may not display correctly when you want to add text for certain commands like `HPDF_Page_TextOut`, `HPDF_Page_ShowText`.  
For this, use this command `haru::hpdf_encode arg1 ?arg2` :
- `arg1` - text
- `arg2` (optional argument) - type encoding (see list [here](http://libharu.sourceforge.net/fonts.html#The_type_of_encodings_)) by default is set to `StandardEncoding (cp1252)`

See **[demo folder](/demo)** for more examples.

Documentation :
-------------------------
Not really... But for `libharu` there is this [one](http://libharu.sourceforge.net/documentation.html).

Special Thanks :
-------------------------
To [Ashok P. Nadkarni](https://github.com/apnadkarni) for helping me understand `tcl-cffi` package and `libharu`.

License :
-------------------------
**haru** is covered under the terms of the [MIT](LICENSE) license.

Release :
-------------------------
*  **10-Feb-2022** : 1.0
    - Initial release.
*  **12-Jun-2022** : 1.1
    - Fixes u3d_demo.tcl, to make it work with libharu 2.3.
    - Ignore some functions if not available. (Windows OS)
*  **24-May-2023** : 1.2
    - Bumped libharu to v2.4.3.
    - Cosmetic changes.
    - Tested on Windows and MacOS.
*  **19-Jun-2025** : 2.0
    - Bumped libharu to `v2.4.5`.
    - Bumped package `tcl-cffi` to v2.*.
    - Support for `Tcl9`.
    - Try checking several places for the location of `libharu` lib.
    - Tested on Windows and MacOS.
    - Incompatibility with previous versions of this package :
        - Use `cffi::enum` instead of global variables (see haru_enum.tcl : HPDF_TRUE, HPDF_COMP_ALL, etc...).
    - Cosmetic changes.
*  **08-Jul-2025** : 2.1
    - Enhanced cross-platform library search functionality.
    - The minimum supported libharu version is now `2.4.3`.
    - Support for multiple versions of libharu until `2.4.5`.