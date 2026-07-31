# Copyright (c) 2022-2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# haru - Tcl binding for libharu (http://libharu.org/) PDF library.

# Define type
cffi::alias define HPDF_Doc          pointer.HPDF_Doc
cffi::alias define HPDF_Page         {pointer.HPDF_Page unsafe}
cffi::alias define HPDF_Destination  pointer.HPDF_Destination
cffi::alias define HPDF_Annotation   pointer.HPDF_Annotation
cffi::alias define HPDF_Font         {pointer.HPDF_Font {onerror haru::NullHandler}}
cffi::alias define HPDF_Outline      pointer.HPDF_Outline
cffi::alias define HPDF_Encoder      pointer.HPDF_Encoder
cffi::alias define HPDF_Image        {pointer.HPDF_Image unsafe {onerror haru::NullHandler}}
cffi::alias define HPDF_Image1       pointer.HPDF_Image1
cffi::alias define HPDF_ExtGState    pointer.HPDF_ExtGState
cffi::alias define HPDF_XObject      HPDF_Image
cffi::alias define HPDF_Dict         pointer.HPDF_Dict
cffi::alias define HPDF_U3D          pointer.HPDF_U3d
cffi::alias define HPDF_3DMeasure    pointer.HPDF_3DMeasure
cffi::alias define HPDF_MMgr         {pointer.HPDF_MMgr   {onerror haru::NullHandler}}
cffi::alias define HPDF_Stream       {pointer.HPDF_Stream {onerror haru::NullHandler}}
cffi::alias define HPDF_Encrypt      pointer.HPDF_Encrypt
cffi::alias define HPDF_FontDef      pointer.HPDF_FontDef
cffi::alias define HPDF_ExData       pointer.HPDF_ExData
cffi::alias define HPDF_EmbeddedFile pointer.HPDF_EmbeddedFile
cffi::alias define HPDF_Shading      pointer.HPDF_Shading

cffi::alias define HPDF_STATUS           {ulong zero}
cffi::alias define HPDF_INT              int
cffi::alias define HPDF_UINT             uint
cffi::alias define HPDF_REAL             float
cffi::alias define HPDF_UINT16           ushort
cffi::alias define HPDF_INT32            int
cffi::alias define HPDF_UNICODE          ushort
cffi::alias define HPDF_UINT8            uchar

# Define struct type
cffi::alias define HPDF_ErrorHandler      {struct.error_handler byref}
cffi::alias define HPDF_Point             struct.hpdfpoint
cffi::alias define HPDF_Point3D           struct.hpdf3Dpoint
cffi::alias define HPDF_TransMatrix       struct.hpdftransmatrix
cffi::alias define HPDF_DashMode          struct.hpdfdashmode
cffi::alias define HPDF_RGBColor          struct.hpdfrgbcolor
cffi::alias define HPDF_CMYKColor         struct.hpdfcmykcolor
cffi::alias define HPDF_Rect              struct.hpdfrect
cffi::alias define HPDF_Box               struct.hpdfbox
cffi::alias define HPDF_TextWidth         struct.hpdftextwidth
cffi::alias define HPDF_Date              struct.hpdfdate

# Define enum type
cffi::alias define HPDF_PageSizes          {int {enum HPdfPageSizes}     {default HPDF_PAGE_SIZE_A4}}
cffi::alias define HPDF_PageDirection      {int {enum HPdfPageDirection} {default HPDF_PAGE_PORTRAIT}}
cffi::alias define HPDF_PageLayout         {int {enum HPdfPageLayout}    {default HPDF_PAGE_LAYOUT_SINGLE}}
cffi::alias define HPDF_PageMode           {int {enum HPdfPageMode}      {default HPDF_PAGE_MODE_USE_NONE}}
cffi::alias define HPDF_PageNumStyle       {int {enum HPdfPageNumStyle}  {default HPDF_PAGE_NUM_STYLE_DECIMAL}}
cffi::alias define HPDF_ColorSpace         {int {enum HPdfColorSpace}    {default HPDF_CS_DEVICE_GRAY}}
cffi::alias define HPDF_InfoType           {int {enum HPdfInfoType}      {default HPDF_INFO_CREATION_DATE}}
cffi::alias define HPDF_EncryptMode        {int {enum HPdfEncryptMode}   {default HPDF_ENCRYPT_R2}}
cffi::alias define HPDF_LineCap            {int {enum HPdfLineCap}}
cffi::alias define HPDF_LineJoin           {int {enum HPdfLineJoin}}
cffi::alias define HPDF_TextRenderingMode  {int {enum HPdfTextRenderingMode}}
cffi::alias define HPDF_TransitionStyle    {int {enum HPdfTransitionStyle}}
cffi::alias define HPDF_TextAlignment      {int {enum HPdfTextAlignment}}
cffi::alias define HPDF_AnnotHighlightMode {int {enum HPdfAnnotHighlightMode}}
cffi::alias define HPDF_AnnotIcon          {int {enum HPdfAnnotIcon}}
cffi::alias define HPDF_BlendMode          {int {enum HPdfBlendMode}}
cffi::alias define HPDF_EncoderType        {int {enum HPdfEncoderType}}
cffi::alias define HPDF_ByteType           {int {enum HPdfByteType}}
cffi::alias define HPDF_WritingMode        {int {enum HPdfWritingMode}}
cffi::alias define HPDF_ShadingType        {int {enum HPdfShadingType}   {default HPDF_SHADING_FREE_FORM_TRIANGLE_MESH}}
cffi::alias define HPDF_Shading_FFTMEF     {int {enum HPdfShading_FreeFormTriangleMeshEdgeFlag}}
cffi::alias define HPDF_BOOL               {int {enum HPdfDefineBool}}
cffi::alias define HPDF_COMP               {int {enum HPdfDefineComp}}
cffi::alias define HPDF_PREF               {int {enum HPdfDefinePreference}}
cffi::alias define HPDF_ENABLE             {int {enum HPdfDefineEnable}}