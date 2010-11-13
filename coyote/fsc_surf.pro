; docformat = 'rst'
;
; NAME:
;   FSC_Surf
;
; PURPOSE:
;   The purpose of FSC_Surf is to create a wrapper for the traditional IDL graphics
;   commands, Surface and Shade_Surf. The primary purpose of this is to create surface 
;   commands that work and look identically both on the display and in PostScript files.
;
;******************************************************************************************;
;                                                                                          ;
;  Copyright (c) 2010, by Fanning Software Consulting, Inc. All rights reserved.           ;
;                                                                                          ;
;  Redistribution and use in source and binary forms, with or without                      ;
;  modification, are permitted provided that the following conditions are met:             ;
;                                                                                          ;
;      * Redistributions of source code must retain the above copyright                    ;
;        notice, this list of conditions and the following disclaimer.                     ;
;      * Redistributions in binary form must reproduce the above copyright                 ;
;        notice, this list of conditions and the following disclaimer in the               ;
;        documentation and/or other materials provided with the distribution.              ;
;      * Neither the name of Fanning Software Consulting, Inc. nor the names of its        ;
;        contributors may be used to endorse or promote products derived from this         ;
;        software without specific prior written permission.                               ;
;                                                                                          ;
;  THIS SOFTWARE IS PROVIDED BY FANNING SOFTWARE CONSULTING, INC. ''AS IS'' AND ANY        ;
;  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES    ;
;  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT     ;
;  SHALL FANNING SOFTWARE CONSULTING, INC. BE LIABLE FOR ANY DIRECT, INDIRECT,             ;
;  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED    ;
;  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;         ;
;  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND             ;
;  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ;
;  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS           ;
;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                            ;
;******************************************************************************************;
;
;+
; :Description:
;   The purpose of FSC_Surf is to create a wrapper for the traditional IDL graphics
;   commands, Surface and Shade_Surf. The primary purpose of this is to create surface 
;   commands that work and look identically both on the display and in PostScript files.
;
; :Categories:
;    Graphics
;    
; :Params:
;    data: in, required, type=any
;         A two-dimensional array of data to be displayed.
;    x: in, optional, type=any
;         A vector or two-dimensional array specifying the X coordinates of the
;         surface grid.
;    y: in, optional, type=any
;         A vector or two-dimensional array specifying the Y coordinates of the
;         surface grid.
;       
; :Keywords:
;     axiscolor: in, optional, type=string/integer, default='black'
;        If this keyword is a string, the name of the axis color. By default, 'black'.
;        Otherwise, the keyword is assumed to be a color index into the current color table.
;     axescolor: in, hidden, type=string/integer
;        Provisions for bad spellers.
;     background: in, optional, type=string/integer, default='white'
;        If this keyword is a string, the name of the background color. By default, 'white'.
;        Otherwise, the keyword is assumed to be a color index into the current color table.
;     bottom: in, optional, type=string/integer, default='black'
;        If this keyword is a string, the name of the bottom color. By default, same as COLOR.
;        Otherwise, the keyword is assumed to be a color index into the current color table.
;     color: in, optional, type=string/integer, default='black'
;        If this keyword is a string, the name of the data color. By default, same as AXISCOLOR.
;        Otherwise, the keyword is assumed to be a color index into the current color table.
;     shaded: in, optional, type=boolean, default=0
;        Set this keyword if you wish to display a shaded surface. To display shaded surfaces
;        in a device-independent way, the shading values are confined to indices 0 to 253 with
;        SET_SHADING, and the background color is placed in color index 254. The color table vectors
;        are reduced to 254 elements when this happens. This all happens behind the stage, 
;        and the original color table is restore upon exit. Because I can't tell how many values
;        SET_SHADING is using on entering the program, I just set it back to its default 256 values
;        on exiting the program.
;     shades: in, optional, type=byte
;        Set this keyword to a byte scaled 2D array of the same size as data to shade the surface
;        with these color indices.
;     xstyle: in, hidden
;         The normal XSTYLE keyword.
;     ystyle: in, hidden
;         The normal YSTYLE keyword.
;     zstyle: in, hidden
;         The normal ZSTYLE keyword.
;     _extra: in, optional, type=any
;        Any keyword appropriate for the IDL Plot command is allowed in the program.
;
; :Examples:
;    Use as you would use the IDL SURFACE of SHADE_SURF command::
;       data = Dist(200)
;       LoadCT, 33
;       FSC_Surf, data
;       FSC_Surf, data, Shades=BytScl(data)
;       FSC_Surf, data, /Shaded
;       FSC_Surf, data, /Shaded, Shades=BytScl(data) 
;       
; :Author:
;       FANNING SOFTWARE CONSULTING::
;           David W. Fanning 
;           1645 Sheely Drive
;           Fort Collins, CO 80526 USA
;           Phone: 970-221-0438
;           E-mail: davidf@dfanning.com
;           Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; :History:
;     Change History::
;        Written, 13 November 2010. DWF.
;
; :Copyright:
;     Copyright (c) 2010, Fanning Software Consulting, Inc.
;-
PRO FSC_Surf, data, x, y, $
    AXISCOLOR=axiscolor, $
    AXESCOLOR=axescolor, $
    BACKGROUND=background, $
    BOTTOM=bottom, $
    COLOR=color, $
    SHADED=shaded, $
    SHADES=shades, $
    XSTYLE=xstyle, $
    YSTYLE=ystyle, $
    ZSTYLE=zstyle, $
    _Extra=extra
    
    Compile_Opt idl2

    Catch, theError
    IF theError NE 0 THEN BEGIN
        Catch, /CANCEL
        void = Error_Message()
        RETURN
    ENDIF
    
    ; Check parameters.
    IF N_Elements(data) EQ 0 THEN BEGIN
        Print, 'USE SYNTAX: FSC_Surf, data, x, y'
        RETURN
    ENDIF
    ndims = Size(data, /N_DIMENSIONS)
    IF ndims NE 2 THEN Message, 'Data must be 2D.'
    s = Size(data, /DIMENSIONS)
    IF N_Elements(x) EQ 0 THEN x = Findgen(s[0])
    IF N_Elements(y) EQ 0 THEN y = Findgen(s[1])
    
    ; Get the current color table vectors.
    TVLCT, rr, gg, bb, /GET
    
    ; Check the keywords.
    IF N_Elements(background) EQ 0 THEN background = 'white'
    IF (N_Elements(axescolor) EQ 0) AND (N_Elements(axiscolor) EQ 0) THEN BEGIN
       axiscolor = 'black'
    ENDIF
    IF N_Elements(axescolor) NE 0 THEN axiscolor = axescolor
    IF N_Elements(color) EQ 0 THEN color = 'black'
    IF N_Elements(bottom) EQ 0 THEN bottom = color
    IF N_Elements(xstyle) EQ 0 THEN xstyle = 0
    IF N_Elements(ystyle) EQ 0 THEN ystyle = 0
    IF N_Elements(zstyle) EQ 0 THEN zstyle = 0
            
    ; Load the drawing colors, if needed. These drawing colors will be done
    ; using decomposed color, so we don't have to "dirty" the color table.
    currentState = DecomposedColor()
    IF Size(axiscolor, /TNAME) EQ 'STRING' THEN BEGIN
        axiscolor = FSC_Color(axiscolor)
    ENDIF ELSE BEGIN
         IF currentState EQ 0 THEN axiscolor = Color24(rr[axiscolor], gg[axiscolor], bb[axiscolor])
    ENDELSE
    IF Size(bottom, /TNAME) EQ 'STRING' THEN BEGIN
        bottom = FSC_Color(bottom)
    ENDIF ELSE BEGIN
         IF currentState EQ 0 THEN bottom = Color24(rr[bottom], gg[bottom], bb[bottom])
    ENDELSE
    IF Size(color, /TNAME) EQ 'STRING' THEN BEGIN
        color = FSC_Color(color)
    ENDIF ELSE BEGIN
         IF currentState EQ 0 THEN color = Color24(rr[color], gg[color], bb[color])
    ENDELSE
    IF Size(background, /TNAME) EQ 'STRING' THEN BEGIN
        originalbg = background
        background = FSC_Color(background)
        shadebackground = FSC_Color(originalbg, DECOMPOSED=0, 254)
    ENDIF ELSE BEGIN
         ; Different values based on current state of the device. Indexed color mode here.
         IF currentState EQ 0 THEN BEGIN
            originalbg = [rr[background], gg[background], bb[background]]
            background = Color24(rr[background], gg[background], bb[background])
         ENDIF
         ; Decomposed color mode here. Not sure how this should be handled. Just
         ; do white. If it is not right, then use strings for color values!
         IF currentState EQ 1 THEN BEGIN
            orginalbg = 'white'
            shadebackground = FSC_Color('white', DECOMPOSED=0, 254)
         ENDIF
    ENDELSE
    
    ; Get the color table with loaded drawing colors.
    TVLCT, rl, gl, bl, /GET
    
    ; Going to draw the axes in decomposed color if we can.
    IF currentState THEN Device, Decomposed=1
    
    ; Draw the surface axes.
    Surface, data, x, y, COLOR=axiscolor, BACKGROUND=background, BOTTOM=bottom, $
        /NODATA, XSTYLE=xstyle, YSTYLE=ystyle, ZSTYLE=zstyle, _STRICT_EXTRA=extra
        
    ; Turn the axes off to draw the surface itself. Start by making sure bit 4 in
    ; the [XYZ]Style bits are turned on.
    IF BitGet(xstyle, 2) NE 1 THEN xxstyle = xstyle + 4 ELSE xxstyle = xstyle
    IF BitGet(ystyle, 2) NE 1 THEN yystyle = ystyle + 4 ELSE yystyle = ystyle
    IF BitGet(zstyle, 2) NE 1 THEN zzstyle = zstyle + 4 ELSE zzstyle = zstyle
         
    ; Make absolutely sure the colors are fresh.
    TVLCT, rr, gg, bb
    
    ; Draw either a wire mesh or shaded surface. Care has to be taken if
    ; the SHADES keyword is used, because this also has to be done in indexed
    ; color mode.
    IF Keyword_Set(shaded) THEN BEGIN
    
        ; All shaded surfaces have to be done in indexed color mode.
        Device, Decomposed=0
        
        ; We have to get the background color out of the surface color
        ; range to do this in a device independent way.
        Set_Shading, VALUES=[0,253]
        
        ; Depending upon the original background color, load the color
        ; in color table index 254.
        IF Size(originalbg, /TNAME) EQ 'STRING' $
            THEN orignalbg = FSC_Color(originalBg, 254) $
            ELSE TVLCT, Reform(origialbg), 254
            
        ; Restrict the current color table vectors to the range 0-253.
        TVLCT, Congrid(rr,254), Congrid(gg,254), Congrid(bb,254)
        
        ; If shades is defined, then we have to make sure the values there
        ; are in the range 0-253.
        IF N_Elements(shades) NE 0 THEN BEGIN
            IF Max(shades,/NAN) GT 253 $
                THEN checkShades = BytScl(shades, TOP=253) $
                ELSE checkShades = shades
        ENDIF
        
        ; Shaded surface plot.
         Shade_Surf, data, x, y, /NOERASE, COLOR=color, BOTTOM=bottom, SHADES=checkShades, $
            XSTYLE=xxstyle, YSTYLE=yystyle, ZSTYLE=zzstyle, _STRICT_EXTRA=extra, $
            BACKGROUND=shadebackground
            
        ; Have to repair the axes. Do this in decomposed color mode, if possible.
        ; If its not possible, you have to reload the color table that has the drawing
        ; colors in it.
        IF currentState THEN Device, Decomposed=1 ELSE TVLCT, rl, gl, bl
        Surface, data, x, y, COLOR=axiscolor, BACKGROUND=background, BOTTOM=bottom, $
            /NODATA, /NOERASE, XSTYLE=xstyle, YSTYLE=ystyle, ZSTYLE=zstyle, _STRICT_EXTRA=extra
            
        ; Shading parameters are "sticky", but I can't tell what they
        ; were when I came into the program. Here is just set them back
        ; to their default values.
        Set_Shading, VALUES=[0,255]
            
    ENDIF ELSE BEGIN
    
        ; We can draw the surface in decomposed color mode, unless the SHADES
        ; keyword is being used. Then we have to use indexed color mode. 
        IF N_Elements(shades) NE 0 THEN BEGIN
            Device, Decomposed=0
            TVLCT, rr, gg, bb
            Surface, data, x, y, /NOERASE, SHADES=shades, $
                XSTYLE=xxstyle, YSTYLE=yystyle, ZSTYLE=zzstyle, _STRICT_EXTRA=extra        
        ENDIF ELSE BEGIN
            IF currentState THEN Device, Decomposed=1 ELSE TVLCT, rl, gl, bl
            Surface, data, x, y, /NOERASE, COLOR=color, BOTTOM=bottom, $
                BACKGROUND=background, SHADES=shades, $
                XSTYLE=xxstyle, YSTYLE=yystyle, ZSTYLE=zzstyle, _STRICT_EXTRA=extra
        ENDELSE
        
    ENDELSE
    
    ; Restore the decomposed color state to the input state.
    IF currentState THEN Device, Decomposed=1 ELSE Device, Decomposed=0

    ; Restore the original color table.
    TVLCT, rr, gg, bb
    
END
    