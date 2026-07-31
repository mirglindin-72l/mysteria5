# Copyright (c) 2022-2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# haru - Tcl binding for libharu (http://libharu.org/) PDF library.

cffi::enum sequence HPdfPageLayout {
    HPDF_PAGE_LAYOUT_SINGLE         
    HPDF_PAGE_LAYOUT_ONE_COLUMN     
    HPDF_PAGE_LAYOUT_TWO_CLUMN_LEFT 
    HPDF_PAGE_LAYOUT_TWO_CLUMN_RIGH 
    HPDF_PAGE_LAYOUT_EOF            
}

cffi::enum sequence HPdfPageMode {
    HPDF_PAGE_MODE_USE_NONE     
    HPDF_PAGE_MODE_USE_OUTLINE  
    HPDF_PAGE_MODE_USE_THUMBS   
    HPDF_PAGE_MODE_FULL_SCREEN  
    HPDF_PAGE_MODE_EOF          
}

cffi::enum sequence HPdfPageSizes {
    HPDF_PAGE_SIZE_LETTER   
    HPDF_PAGE_SIZE_LEGAL    
    HPDF_PAGE_SIZE_A3       
    HPDF_PAGE_SIZE_A4       
    HPDF_PAGE_SIZE_A5       
    HPDF_PAGE_SIZE_B4       
    HPDF_PAGE_SIZE_B5       
    HPDF_PAGE_SIZE_EXECUTIVE
    HPDF_PAGE_SIZE_US4x6    
    HPDF_PAGE_SIZE_US4x8    
    HPDF_PAGE_SIZE_US5x7     
    HPDF_PAGE_SIZE_COMM10    
    HPDF_PAGE_SIZE_EOF       
}

cffi::enum sequence HPdfPageDirection {
    HPDF_PAGE_PORTRAIT 
    HPDF_PAGE_LANDSCAPE
}

cffi::enum sequence HPdfPageNumStyle {
    HPDF_PAGE_NUM_STYLE_DECIMAL      
    HPDF_PAGE_NUM_STYLE_UPPER_ROMAN  
    HPDF_PAGE_NUM_STYLE_LOWER_ROMAN  
    HPDF_PAGE_NUM_STYLE_UPPER_LETTERS
    HPDF_PAGE_NUM_STYLE_LOWER_LETTERS
    HPDF_PAGE_NUM_STYLE_EOF          
}

cffi::enum sequence HPdfWritingMode {
    HPDF_WMODE_HORIZONTAL
    HPDF_WMODE_VERTICAL  
    HPDF_WMODE_EOF       
}

cffi::enum sequence HPdfEncoderType {
    HPDF_ENCODER_TYPE_SINGLE_BYTE  
    HPDF_ENCODER_TYPE_DOUBLE_BYTE  
    HPDF_ENCODER_TYPE_UNINITIALIZED
    HPDF_ENCODER_UNKNOWN           
}

cffi::enum sequence HPdfByteType {
    HPDF_BYTE_TYPE_SINGLE 
    HPDF_BYTE_TYPE_LEAD   
    HPDF_BYTE_TYPE_TRIAL  
    HPDF_BYTE_TYPE_UNKNOWN
}

cffi::enum sequence HPdfAnnotHighlightMode {
    HPDF_ANNOT_NO_HIGHTLIGHT      
    HPDF_ANNOT_INVERT_BOX         
    HPDF_ANNOT_INVERT_BORDER      
    HPDF_ANNOT_DOWN_APPEARANCE    
    HPDF_ANNOT_HIGHTLIGHT_MODE_EOF
}

cffi::enum sequence HPdfAnnotIcon {
    HPDF_ANNOT_ICON_COMMENT      
    HPDF_ANNOT_ICON_KEY          
    HPDF_ANNOT_ICON_NOTE         
    HPDF_ANNOT_ICON_HELP         
    HPDF_ANNOT_ICON_NEW_PARAGRAPH
    HPDF_ANNOT_ICON_PARAGRAPH    
    HPDF_ANNOT_ICON_INSERT       
    HPDF_ANNOT_ICON_EOF          
}

cffi::enum sequence HPdfColorSpace {
    HPDF_CS_DEVICE_GRAY
    HPDF_CS_DEVICE_RGB 
    HPDF_CS_DEVICE_CMYK
    HPDF_CS_CAL_GRAY   
    HPDF_CS_CAL_RGB    
    HPDF_CS_LAB        
    HPDF_CS_ICC_BASED  
    HPDF_CS_SEPARATION 
    HPDF_CS_DEVICE_N   
    HPDF_CS_INDEXED    
    HPDF_CS_PATTERN     
    HPDF_CS_EOF         
}
cffi::enum sequence HPdfInfoType {
    HPDF_INFO_CREATION_DATE
    HPDF_INFO_MOD_DATE     
    HPDF_INFO_AUTHOR       
    HPDF_INFO_CREATOR      
    HPDF_INFO_PRODUCER     
    HPDF_INFO_TITLE        
    HPDF_INFO_SUBJECT      
    HPDF_INFO_KEYWORDS     
    HPDF_INFO_EOF          
}

cffi::enum sequence HPdfEncryptMode {
    HPDF_ENCRYPT_R2
    HPDF_ENCRYPT_R3
}

cffi::enum sequence HPdfTextRenderingMode {
    HPDF_FILL                
    HPDF_STROKE              
    HPDF_FILL_THEN_STROKE    
    HPDF_INVISIBLE           
    HPDF_FILL_CLIPPING       
    HPDF_STROKE_CLIPPING     
    HPDF_FILL_STROKE_CLIPPING
    HPDF_CLIPPING            
    HPDF_RENDERING_MODE_EOF  
}

cffi::enum sequence HPdfLineCap {
    HPDF_BUTT_END             
    HPDF_ROUND_END            
    HPDF_PROJECTING_SCUARE_END
    HPDF_LINECAP_EOF          
}

cffi::enum sequence HPdfLineJoin {
    HPDF_MITER_JOIN  
    HPDF_ROUND_JOIN  
    HPDF_BEVEL_JOIN  
    HPDF_LINEJOIN_EOF
}

cffi::enum sequence HPdfTextAlignment {
    HPDF_TALIGN_LEFT   
    HPDF_TALIGN_RIGHT  
    HPDF_TALIGN_CENTER 
    HPDF_TALIGN_JUSTIFY
}

cffi::enum sequence HPdfTransitionStyle {
    HPDF_TS_WIPE_RIGHT                     
    HPDF_TS_WIPE_UP                        
    HPDF_TS_WIPE_LEFT                      
    HPDF_TS_WIPE_DOWN                      
    HPDF_TS_BARN_DOORS_HORIZONTAL_OUT      
    HPDF_TS_BARN_DOORS_HORIZONTAL_IN       
    HPDF_TS_BARN_DOORS_VERTICAL_OUT        
    HPDF_TS_BARN_DOORS_VERTICAL_IN         
    HPDF_TS_BOX_OUT                        
    HPDF_TS_BOX_IN                         
    HPDF_TS_BLINDS_HORIZONTAL               
    HPDF_TS_BLINDS_VERTICAL                 
    HPDF_TS_DISSOLVE                        
    HPDF_TS_GLITTER_RIGHT                   
    HPDF_TS_GLITTER_DOWN                    
    HPDF_TS_GLITTER_TOP_LEFT_TO_BOTTOM_RIGHT
    HPDF_TS_REPLACE                         
    HPDF_TS_EOF                             
}

cffi::enum sequence HPdfBlendMode {
    HPDF_BM_NORMAL     
    HPDF_BM_MULTIPLY   
    HPDF_BM_SCREEN     
    HPDF_BM_OVERLAY    
    HPDF_BM_DARKEN     
    HPDF_BM_LIGHTEN    
    HPDF_BM_COLOR_DODGE
    HPDF_BM_COLOR_BUM  
    HPDF_BM_HARD_LIGHT 
    HPDF_BM_SOFT_LIGHT 
    HPDF_BM_DIFFERENCE  
    HPDF_BM_EXCLUSHON   
    HPDF_BM_EOF         
}

cffi::enum define HPdfShadingType {
    HPDF_SHADING_FREE_FORM_TRIANGLE_MESH 4
}

cffi::enum sequence HPdfShading_FreeFormTriangleMeshEdgeFlag {
    HPDF_FREE_FORM_TRI_MESH_EDGEFLAG_NO_CONNECTION     
    HPDF_FREE_FORM_TRI_MESH_EDGEFLAG_BC   
    HPDF_FREE_FORM_TRI_MESH_EDGEFLAG_AC        
}

cffi::enum define HPdfDefineBool {
    HPDF_TRUE  1
    HPDF_FALSE 0
}

cffi::enum define HPdfDefineComp {
    HPDF_COMP_NONE     0
    HPDF_COMP_TEXT     1
    HPDF_COMP_IMAGE    2
    HPDF_COMP_METADATA 4
    HPDF_COMP_ALL      15
}

cffi::enum define HPdfDefinePreference {
    HPDF_HIDE_TOOLBAR        1
    HPDF_HIDE_MENUBAR        2
    HPDF_HIDE_WINDOW_UI      4
    HPDF_FIT_WINDOW          8
    HPDF_CENTER_WINDOW       16
    HPDF_PRINT_SCALING_NONE  32
}

cffi::enum define HPdfDefineEnable {
    HPDF_ENABLE_READ     0
    HPDF_ENABLE_PRINT    4
    HPDF_ENABLE_EDIT_ALL 8
    HPDF_ENABLE_COPY     16
    HPDF_ENABLE_EDIT     32
}