; docformat = 'rst'
;
; NAME:
;   cgPlot
;
; PURPOSE:
;   The purpose of cgPlot is to create a wrapper for the traditional IDL graphics
;   command, Plot. The primary purpose of this is to create plot commands that work
;   and look identically both on the display and in PostScript files.
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
;   The purpose of cgPlot is to create a wrapper for the traditional IDL graphics
;   command, Plot. The primary purpose of this is to create plot commands that work
;   and look identically both on the display and in PostScript files.
;
; :Categories:
;    Graphics
;    
; :Params:
;    x: in, required, type=any
;         If X is provided without Y, a vector representing the dependent values to be 
;         plotted If both X and Y are provided, X is the independent parameter and 
;         Y is the dependent parameter to be plotted.
;    y: in, optional, type=any
;         A vector representing the dependent values to be plotted.
;       
; :Keywords:
;     addcmd: in, optional, type=boolean, default=0
;       Set this keyword to add the command to the resizeable graphics window cgWindow.
;     aspect: in, optional, type=float, default=none
;        Set this keyword to a floating point ratio that represents the aspect ratio 
;        (ysize/xsize) of the resulting plot. The plot position may change as a result
;        of setting this keyword. Note that ASPECT cannot be used when plotting with
;        !P.MULTI.
;     axiscolor: in, optional, type=string/integer, default='black'
;        If this keyword is a string, the name of the axis color. By default, 'black'.
;        Otherwise, the keyword is assumed to be a color index into the current color table.
;     axescolor: in, optional, type=string/integer
;        Provisions for bad spellers.
;     background: in, optional, type=string/integer, default='white'
;        If this keyword is a string, the name of the background color. By default, 'white'.
;        Otherwise, the keyword is assumed to be a color index into the current color table.
;     charsize: in, optional, type=float, default=cgDefCharSize()
;        The character size for axes annotations. Uses cgDefCharSize to select default
;        character size, unless !P.Charsize is set, in which case !P.Charsize is always used.
;     color: in, optional, type=string/integer, default='black'
;        If this keyword is a string, the name of the data color. By default, 'black'.
;        Color names are those used with cgColor. Otherwise, the keyword is assumed 
;        to be a color index into the current color table.
;     font: in, optional, type=integer, default=!P.Font
;        The type of font desired for axis annotation.
;     isotropic: in, optional, type=boolean, default=0
;        A short-hand way of setting the ASPECT keyword to 1.
;     layout: in, optional, type=intarr(3)
;        This keyword specifies a grid with a graphics window and determines where the
;        graphic should appear. The syntax of LAYOUT is three numbers: [ncolumns, nrows, location].
;        The grid is determined by the number of columns (ncolumns) by the number of 
;        rows (nrows). The location of the graphic is determined by the third number. The
;        grid numbering starts in the upper left (1) and goes sequentually by column and then
;        by row.
;     nodata: in, optional, type=boolean, default=0
;        Set this keyword to draw axes, but no data.
;     noerase: in, optional, type=boolean, default=0
;        Set this keyword to draw the plot without erasing the display first.
;     outfilename: in, optional, type=string
;        If the `Output` keyword is set, the user will be asked to supply an output
;        filename, unless this keyword is set to a non-null string. In that case, the
;        value of this keyword will be used as the filename and there will be no dialog
;        presented to the user.
;     output: in, optional, type=string, default=""
;        Set this keyword to the type of output desired. Possible values are these::
;            
;            'PS'   - PostScript file
;            'EPS'  - Encapsulated PostScript file
;            'PDF'  - PDF file
;            'BMP'  - BMP raster file
;            'GIF'  - GIF raster file
;            'JPEG' - JPEG raster file
;            'PNG'  - PNG raster file
;            'TIFF' - TIFF raster file
;            
;        Note that ImageMagick and Ghostview MUST be installed for anything other than PostScript
;        output to work. (See cgPS2PDF and PS_END for details.) And also note that you should
;        NOT use this keyword when doing multiple plots. It is really just to be used as a
;        convenient way to get output for a single plot command.
;     overplot: in, optional, type=boolean, default=0
;        Set this keyword if you wish to overplot data on an already exisiting set of
;        axes. It is like calling the IDL OPLOT command.
;     position: in, optional, type=vector
;        The usual four-element position vector for the Plot comamnd. Only monitored and
;        possibly set if the ASPECT keyword is used.
;     psym: in, optional, type=integer
;        Any normal IDL PSYM values, plus and value supported by the Coyote Library
;        routine SYMCAT. An integer between 0 and 46.
;     symcolor: in, optional, type=string/integer, default='black'
;        If this keyword is a string, the name of the symbol color. By default, 'black'.
;        Otherwise, the keyword is assumed to be a color index into the current color table.
;     symsize: in, optional, type=float, default=1.0
;        The symbol size.
;     traditional: in, optional, type=boolean, default=0
;        If this keyword is set, the traditional color scheme of a black background for
;        graphics windows on the display is used and PostScript files always use a white background.
;     window: in, optional, type=boolean, default=0
;        Set this keyword to replace all the commands in a current cgWindow or to
;        create a new cgWindow for displaying this command.
;     _ref_extra: in, optional, type=any
;        Any keyword appropriate for the IDL Plot command is allowed in the program.
;
; :Examples:
;    Use as you would use the IDL PLOT command::
;       cgPlot, Findgen(11)
;       cgPlot, Findgen(11), Aspect=1.0
;       cgPlot, Findgen(11), Color='olive', AxisColor='red', Thick=2
;       cgPlot, Findgen(11), Color='blue', SymColor='red', PSym=-16
;       
; :Author:
;    FANNING SOFTWARE CONSULTING::
;        David W. Fanning 
;        1645 Sheely Drive
;        Fort Collins, CO 80526 USA
;        Phone: 970-221-0438
;        E-mail: david@idlcoyote.com
;        Coyote's Guide to IDL Programming: http://www.idlcoyote.com
;
; :History:
;     Change History::
;        Written, 12 November 2010. DWF.
;        Added SYMCOLOR keyword, and allow all 46 symbols from SYMCAT. 15 November 2010. DWF.
;        Added NODATA keyword. 15 November 2010. DWF.
;        Now setting decomposition state by calling SetDecomposedState. 16 November 2010. DWF.
;        Final color table restoration skipped in Z-graphics buffer. 17 November 2010. DWF.
;        Fixed a problem with overplotting with symbols. 17 November 2010. DWF.
;        Background keyword now applies in PostScript file as well. 17 November 2010. DWF.
;        Many changes after BACKGROUND changes to get !P.MULTI working again! 18 November 2010. DWF.
;        Fixed a small problem with the OVERPLOT keyword. 18 Nov 2010. DWF.
;        Changes so that color inputs don't change type. 23 Nov 2010. DWF.
;        Added WINDOW keyword to allow graphic to be displayed in a resizable graphics window. 8 Dec 2010. DWF
;        Modifications to allow cgPlot to be drop-in replacement for old PLOT commands in 
;            indexed color mode. 24 Dec 2010. DWF.
;        Previous changes introduced problems with OVERPLOT that have now been fixed. 28 Dec 2010. DWF.
;        Set NOERASE keyword from !P.NoErase system variable when appropriate. 28 Dec 2010. DWF.
;        Additional problems with NOERASE discovered and solved. 29 Dec 2010. DWF.
;        In some cases, I was turning BYTE values to strings without converting to 
;            INTEGERS first. 30 Dec 2010. DWF.  
;         Selecting character size now with cgDefCharSize. 11 Jan 2011. DWF.   
;         Moved setting to decomposed color before color selection process to avoid PostScript
;             background problems when passed 24-bit color integers. 12 Jan 2011. DWF. 
;         Changed _EXTRA to _REF_EXTRA on procedure definition statement to be able to return
;             plot keywords such as XGET_TICKS. 13 Jan 2011. DWF.  
;         Added SYMSIZE keyword. 16 Jan 2011. DWF.
;         Fixed a problem in which I assumed the background color was a string. 18 Jan 2011. DWF.  
;         Added ADDCMD keyword. 26 Jan 2011. DWF.
;         Added LAYOUT keyword. 28 Jan 2011. DWF.
;         Made a modification that allows THICK and COLOR keywords apply to symbols, too. 24 Feb 2011. DWF.
;         Modified error handler to restore the entry decomposition state if there is an error. 17 March 2011. DWF
;         Somehow I had gotten independent and dependent data reversed in the code. Put right. 16 May 2011. DWF.
;         Allowed ASPECT (and /ISOTROPIC) to take into account input POSITION. 15 June 2011. Jeremy Bailin.
;         Updated the BACKGROUND color selection from lessons learned in 27 Oct 2011 cgContour 
;             corrections. 27 Oct 2011. DWF.
;         Added the ability to send the output directly to a file via the OUTPUT keyword. 9 Dec 2011, DWF.
;         
; :Copyright:
;     Copyright (c) 2010-2011, Fanning Software Consulting, Inc.
;-
PRO cgPlot, x, y, $
    ADDCMD=addcmd, $
    ASPECT=aspect, $
    AXISCOLOR=saxiscolor, $
    AXESCOLOR=saxescolor, $
    BACKGROUND=sbackground, $
    CHARSIZE=charsize, $
    COLOR=scolor, $
    FONT=font, $
    ISOTROPIC=isotropic, $
    LAYOUT=layout, $
    NODATA=nodata, $
    NOERASE=noerase, $
    OUTFILENAME=outfilename, $
    OUTPUT=output, $
    OVERPLOT=overplot, $
    POSITION=position, $
    PSYM=psym, $
    SYMCOLOR=ssymcolor, $
    SYMSIZE=symsize, $
    TRADITIONAL=traditional, $
    WINDOW=window, $
    _REF_EXTRA=extra
    
    Compile_Opt idl2

    Catch, theError
    IF theError NE 0 THEN BEGIN
        Catch, /CANCEL
        void = Error_Message()
        IF N_Elements(thisMulti) NE 0 THEN !P.Multi = thisMulti
        IF N_Elements(currentState) NE 0 THEN SetDecomposedState, currentState
        IF (N_Elements(output) NE 0) THEN PS_END, /NOFIX
        RETURN
    ENDIF
    
    ; Set up PostScript device for working with colors.
    IF !D.Name EQ 'PS' THEN Device, COLOR=1, BITS_PER_PIXEL=8
    
    ; Check parameters.
    IF N_Params() EQ 0 THEN BEGIN
        Print, 'USE SYNTAX: cgPlot, x, y'
        RETURN
    ENDIF
    
    ; Pay attention to !P.Noerase in setting the NOERASE kewyord. This must be
    ; done BEFORE checking the LAYOUT properties.
    IF !P.NoErase NE 0 THEN noerase = !P.NoErase ELSE noerase = Keyword_Set(noerase)
    
    ; Do they want this plot in a resizeable graphics window?
    IF Keyword_Set(addcmd) THEN window = 1
    IF Keyword_Set(window) AND ((!D.Flags AND 256) NE 0) THEN BEGIN
    
        ; If you are using a layout, you can't ever erase.
        IF N_Elements(layout) NE 0 THEN noerase = 1
        
        ; Special treatment for overplotting or adding a command.
        IF Keyword_Set(overplot) OR Keyword_Set(addcmd) THEN BEGIN
        cgWindow, 'cgPlot', x, y, $
            ASPECT=aspect, $
            AXISCOLOR=saxiscolor, $
            AXESCOLOR=saxescolor, $
            BACKGROUND=sbackground, $
            CHARSIZE=charsize, $
            COLOR=scolor, $
            FONT=font, $
            ISOTROPIC=isotropic, $
            LAYOUT=layout, $
            NODATA=nodata, $
            NOERASE=noerase, $
            OVERPLOT=overplot, $
            POSITION=position, $
            PSYM=psym, $
            SYMCOLOR=ssymcolor, $
            SYMSIZE=symsize, $
            TRADITIONAL=traditional, $
            ADDCMD=1, $
            _Extra=extra
             RETURN
       ENDIF
        
        ; Open a new window or replace the current commands, as required.
        currentWindow = cgQuery(/CURRENT, COUNT=wincnt)
        IF wincnt EQ 0 THEN replaceCmd = 0 ELSE replaceCmd=1
        cgWindow, 'cgPlot', x, y, $
            ASPECT=aspect, $
            AXISCOLOR=saxiscolor, $
            AXESCOLOR=saxescolor, $
            BACKGROUND=sbackground, $
            CHARSIZE=charsize, $
            COLOR=scolor, $
            FONT=font, $
            ISOTROPIC=isotropic, $
            LAYOUT=layout, $
            NODATA=nodata, $
            NOERASE=noerase, $
            OVERPLOT=overplot, $
            POSITION=position, $
            PSYM=psym, $
            SYMCOLOR=ssymcolor, $
            SYMSIZE=symsize, $
            TRADITIONAL=traditional, $
            REPLACECMD=replaceCmd, $
            _Extra=extra
            
         RETURN
    ENDIF
    
    ; Sort out which is the dependent and which is independent data.
    CASE N_Params() OF
      
       1: BEGIN
       indep = x
       dep = Findgen(N_Elements(indep))
       ENDCASE
    
       2: BEGIN
       indep = y
       dep = x
       ENDCASE
    
    ENDCASE
    
    ; Are we doing some kind of output?
    IF (N_Elements(output) NE 0) && (output NE "") THEN BEGIN
    
       outputSelection = StrUpCase(output)
       typeOfOutput = ['PS','EPS','PDF','BMP','GIF','JPEG','PNG','TIFF']
       void = Where(typeOfOutput EQ outputSelection, count)
       IF count EQ 0 THEN Message, 'Cannot find ' + outputSelection + ' in allowed output types.'
       
       ; Set things up.
       CASE outputSelection OF
          
          'PS': BEGIN
              ext = '.ps'
              delete_ps = 0
              END
       
          'EPS': BEGIN
              ext = '.eps'
              encapsulated = 1
              delete_ps = 0
              END

          'PDF': BEGIN
              ext = '.pdf'
              pdf_flag = 1
              delete_ps = 1
              END
       
          'BMP': BEGIN
              ext = '.bmp'
              bmp_flag = 1
              delete_ps = 1
              END
       
          'GIF': BEGIN
              ext = '.gif'
              gif_flag = 1
              delete_ps = 1
              END
       
          'JPEG': BEGIN
              ext = '.jpg'
              jpeg_flag = 1
              delete_ps = 1
              END
       
          'PNG': BEGIN
              ext = '.png'
              png_flag = 1
              delete_ps = 1
              END
       
          'TIFF': BEGIN
              ext = '.tif'
              tiff_flag = 1
              delete_ps = 1
              END
       
       
       ENDCASE
       
       ; Do you need a filename?
       IF ( (N_Elements(outfilename) EQ 0) || (outfilename EQ "") ) THEN BEGIN 
            filename = 'cgplot' + ext
            outfilename = cgPickfile(FILE=filename, TITLE='Select Output File Name...', $
                FILTER=ext, /WRITE)
            IF outfilename EQ "" THEN RETURN
       ENDIF
       
       ; We need to know the root name of the file, because we have to make a PostScript
       ; file of the same name. At least we do if the type is not PS or EPS.
       IF (outputSelection NE 'PS') && (outputSelection NE 'EPS') THEN BEGIN
           root_name = FSC_Base_Filename(outfilename, DIRECTORY=theDir)
           IF theDir EQ "" THEN CD, CURRENT=theDir
           ps_filename = Filepath(ROOT_DIR=theDir, root_name + '.ps')
       ENDIF ELSE ps_filename = outfilename
       
       ; Set up the PostScript device.
       PS_Start, FILENAME=ps_filename, ENCAPSULATED=encapsulated, QUIET=1
    
    ENDIF
   
    ; Get the current color table vectors.
    TVLCT, rr, gg, bb, /GET
    
    ; Going to do this in decomposed color, if possible.
    SetDecomposedState, 1, CURRENTSTATE=currentState
    
    ; Set up the layout, if necessary.
    IF N_Elements(layout) NE 0 THEN BEGIN
       thisMulti = !P.Multi
       totalPlots = layout[0]*layout[1]
       !P.Multi = [0,layout[0], layout[1], 0, 0]
       IF layout[2] EQ 1 THEN BEGIN
            noerase = 1
            !P.Multi[0] = 0
       ENDIF ELSE BEGIN
            !P.Multi[0] = totalPlots - layout[2] + 1
       ENDELSE
    ENDIF

    ; Check the keywords.
    IF N_Elements(sbackground) EQ 0 THEN BEGIN
        IF Keyword_Set(overplot) || Keyword_Set(noerase) THEN BEGIN
           IF !D.Name EQ 'PS' THEN BEGIN
                background = 'WHITE' 
           ENDIF ELSE BEGIN
                IF ((!D.Flags AND 256) NE 0) THEN BEGIN
                    havewindow = 0
                    IF (!D.Window LT 0) &&  Keyword_Set(noerase) THEN BEGIN
                        Window
                        IF ~Keyword_Set(traditional) THEN cgErase, 'WHITE'
                        havewindow = 1
                    ENDIF ELSE BEGIN
                        IF (!D.Window GE 0) THEN BEGIN
                           WSet, !D.Window
                           havewindow = 1
                        ENDIF ELSE BEGIN
                           wid = cgQuery(/CURRENT)
                           IF wid GE 0 THEN BEGIN
                               WSet, wid
                               havewindow = 1
                           ENDIF
                        ENDELSE
                    ENDELSE
                    IF havewindow THEN BEGIN
                        pixel = cgSnapshot(!D.X_Size-1,  !D.Y_Size-1, 1, 1)
                        IF (Total(pixel) EQ 765) THEN background = 'WHITE'
                        IF (Total(pixel) EQ 0) THEN background = 'BLACK'
                    ENDIF ELSE background = 'WHITE'
                    IF N_Elements(background) EQ 0 THEN background = 'OPPOSITE'
                ENDIF ELSE background = 'OPPOSITE'
           ENDELSE
        ENDIF ELSE BEGIN
           IF Keyword_Set(traditional) THEN BEGIN
              IF ((!D.Flags AND 256) NE 0) THEN background = 'BLACK' ELSE background = 'WHITE'
           ENDIF ELSE background = 'WHITE' 
        ENDELSE
    ENDIF ELSE background = sbackground
    IF Size(background, /TYPE) EQ 3 THEN IF GetDecomposedState() EQ 0 THEN background = Byte(background)
    IF Size(background, /TYPE) LE 2 THEN background = StrTrim(Fix(background),2)
    
    ; Choose an axis color.
    IF N_Elements(saxisColor) EQ 0 AND N_Elements(saxescolor) NE 0 THEN saxiscolor = saxescolor
    IF N_Elements(saxiscolor) EQ 0 THEN BEGIN
       IF (Size(background, /TNAME) EQ 'STRING') && (StrUpCase(background) EQ 'WHITE') THEN BEGIN
            IF !P.Multi[0] EQ 0 THEN saxisColor = 'BLACK'
       ENDIF
       IF N_Elements(saxiscolor) EQ 0 THEN BEGIN
           IF !D.Name EQ 'PS' THEN BEGIN
                IF StrUpCase(background) EQ 'BLACK' THEN background = 'WHITE'
                saxisColor = 'BLACK' 
           ENDIF ELSE BEGIN
                IF ((!D.Flags AND 256) NE 0) THEN BEGIN
                    IF !D.Window LT 0 THEN Window
                    IF (!P.Multi[0] EQ 0) && (~Keyword_Set(overplot) && ~noerase) THEN cgErase, background
                    pixel = cgSnapshot(!D.X_Size-1,  !D.Y_Size-1, 1, 1)
                    IF (Total(pixel) EQ 765) OR (StrUpCase(background) EQ 'WHITE') THEN saxisColor = 'BLACK'
                    IF (Total(pixel) EQ 0) OR (StrUpCase(background) EQ 'BLACK') THEN saxisColor = 'WHITE'
                    IF N_Elements(saxisColor) EQ 0 THEN saxisColor = 'OPPOSITE'
                ENDIF ELSE saxisColor = 'OPPOSITE'
          ENDELSE
       ENDIF
    ENDIF
    IF N_Elements(saxisColor) EQ 0 THEN axisColor = !P.Color ELSE axisColor = saxisColor
    IF Size(axisColor, /TYPE) EQ 3 THEN IF GetDecomposedState() EQ 0 THEN axisColor = Byte(axisColor)
    IF Size(axisColor, /TYPE) LE 2 THEN axisColor = StrTrim(Fix(axisColor),2)
    
    ; Choose a color.
    IF N_Elements(sColor) EQ 0 THEN BEGIN
       IF (Size(background, /TNAME) EQ 'STRING') && (StrUpCase(background) EQ 'WHITE') THEN BEGIN
            IF !P.Multi[0] EQ 0 THEN sColor = 'BLACK'
       ENDIF
       IF N_Elements(sColor) EQ 0 THEN BEGIN
           IF !D.Name EQ 'PS' THEN BEGIN
                IF StrUpCase(background) EQ 'BLACK' THEN background = 'WHITE'
                sColor = 'BLACK' 
           ENDIF ELSE BEGIN
                IF ((!D.Flags AND 256) NE 0) THEN BEGIN
                    IF !D.Window LT 0 THEN Window
                    IF (!P.Multi[0] EQ 0) && (~Keyword_Set(overplot) && ~noerase) THEN cgErase, background
                    pixel = cgSnapshot(!D.X_Size-1,  !D.Y_Size-1, 1, 1)
                    IF (Total(pixel) EQ 765) OR (StrUpCase(background) EQ 'WHITE') THEN sColor = 'BLACK'
                    IF (Total(pixel) EQ 0) OR (StrUpCase(background) EQ 'BLACK') THEN sColor = 'WHITE'
                    IF N_Elements(sColor) EQ 0 THEN sColor = 'OPPOSITE'
                ENDIF ELSE sColor = 'OPPOSITE'
           ENDELSE
       ENDIF
    ENDIF
    IF N_Elements(sColor) EQ 0 THEN color = !P.Color ELSE  color = sColor
    IF Size(color, /TYPE) EQ 3 THEN IF GetDecomposedState() EQ 0 THEN color = Byte(color)
    IF Size(color, /TYPE) LE 2 THEN color = StrTrim(Fix(color),2)
    
    ; If color is the same as background, do something.
    IF ColorsAreIdentical(background, color) THEN BEGIN
        IF ((!D.Flags AND 256) NE 0) THEN BEGIN
           IF (!P.Multi[0] EQ 0) && (~Keyword_Set(overplot) && ~noerase) THEN cgErase, background
        ENDIF
        color = 'OPPOSITE'
    ENDIF
    IF ColorsAreIdentical(background, axiscolor) THEN BEGIN
        IF ((!D.Flags AND 256) NE 0) THEN BEGIN
           IF (!P.Multi[0] EQ 0) && (~Keyword_Set(overplot) && ~noerase) THEN cgErase, background
        ENDIF
        axiscolor = 'OPPOSITE'
    ENDIF
    
    ; Character size has to be determined *after* the layout has been decided.
    IF N_Elements(font) EQ 0 THEN font = !P.Font
    IF N_Elements(charsize) EQ 0 THEN charsize = cgDefCharSize(FONT=font)
    
    ; Other keywords.
    IF N_Elements(ssymcolor) EQ 0 THEN symcolor = color ELSE symcolor = ssymcolor
    IF N_Elements(symsize) EQ 0 THEN symsize = 1.0
    IF Size(symcolor, /TYPE) EQ 3 THEN IF GetDecomposedState() EQ 0 THEN symcolor = Byte(symcolor)
    IF Size(symcolor, /TYPE) LE 2 THEN symcolor = StrTrim(Fix(symcolor),2)
    IF Keyword_Set(isotropic) THEN aspect = 1.0
    IF N_Elements(psym) EQ 0 THEN psym = 0
    IF (N_Elements(aspect) NE 0) AND (Total(!P.MULTI) EQ 0) THEN BEGIN
    
        ; If position is set, then fit the plot into those bounds.
        IF (N_Elements(position) GT 0) THEN BEGIN
          trial_position = Aspect(aspect, margin=0.)
          trial_width = trial_position[2]-trial_position[0]
          trial_height = trial_position[3]-trial_position[1]
          pos_width = position[2]-position[0]
          pos_height = position[3]-position[1]

          ; Same logic as cgImage: try to fit image width, then if you can't get the right aspect
          ; ratio, fit the image height instead.
          fit_ratio = pos_width / trial_width
          IF trial_height * fit_ratio GT pos_height THEN $
             fit_ratio = pos_height / trial_height

          ; new width and height
          trial_width *= fit_ratio
          trial_height *= fit_ratio

          ; calculate position vector based on trial_width and trial_height
          position[0] += 0.5*(pos_width - trial_width)
          position[2] -= 0.5*(pos_width - trial_width)
          position[1] += 0.5*(pos_height - trial_height)
          position[3] -= 0.5*(pos_height - trial_height)
        ENDIF ELSE position=Aspect(aspect)   ; if position isn't set, just use output of Aspect
        
    ENDIF
           
    ; Do you need a PostScript background color? Lot's of problems here!
    ; Basically, I MUST draw a plot to advance !P.MULTI. But, drawing a
    ; plot of any sort erases the background color. So, I have to draw a 
    ; plot, store the new system variables, then draw my background, etc.
    ; I have tried LOTS of options. This is the only one that worked.
    IF !D.Name EQ 'PS' THEN BEGIN
         IF ~noerase THEN BEGIN
       
           ; I only have to do this, if this is the first plot.
           IF !P.MULTI[0] EQ 0 THEN BEGIN
           
                IF Keyword_Set(overplot) NE 1 THEN BEGIN
                
                    ; Save the current system variables. Will need to restore later.
                    bangx = !X
                    bangy = !Y
                    bangp = !P
                    
                    ; Draw the plot that doesn't draw anything.
                    Plot, dep, indep, POSITION=position, CHARSIZE=charsize, /NODATA, $
                        FONT=font, _STRICT_EXTRA=extra  
                    
                    ; Save the "after plot" system variables. Will use later. 
                    afterx = !X
                    aftery = !Y
                    afterp = !P     
                    
                    ; Draw the background color and set the variables you will need later.
                    PS_Background, background
                    psnodraw = 1
                    tempNoErase = 1
                    
                    ; Restore the original system variables so that it is as if you didn't
                    ; draw the invisible plot.
                    !X = bangx
                    !Y = bangy
                    !P = bangp
                
                ENDIF
            ENDIF ELSE tempNoErase = noerase
        ENDIF ELSE tempNoErase = noerase
     ENDIF ELSE tempNoErase = noerase
 
    
     ; Load the drawing colors, if needed.
    IF Size(axiscolor, /TNAME) EQ 'STRING' THEN axiscolor = cgColor(axiscolor)
    IF Size(color, /TNAME) EQ 'STRING' THEN color = cgColor(color)
    IF Size(background, /TNAME) EQ 'STRING' THEN background = cgColor(background)
    IF Size(symcolor, /TNAME) EQ 'STRING' THEN symcolor = cgColor(symcolor)
    
    ; Draw the plot.
    IF Keyword_Set(overplot) THEN BEGIN
       IF psym LE 0 THEN OPlot, dep, indep, COLOR=color, _STRICT_EXTRA=extra
    ENDIF ELSE BEGIN
      Plot, dep, indep, BACKGROUND=background, COLOR=axiscolor, CHARSIZE=charsize, $
            POSITION=position, /NODATA, NOERASE=tempNoErase, FONT=font, _STRICT_EXTRA=extra
        IF psym LE 0 THEN BEGIN
           IF ~Keyword_Set(nodata) THEN OPlot, dep, indep, COLOR=color, _EXTRA=extra  
        ENDIF  
    ENDELSE
    IF Abs(psym) GT 0 THEN BEGIN
        IF ~Keyword_Set(nodata) THEN OPlot, dep, indep, COLOR=symcolor, $
            PSYM=SymCat(Abs(psym), COLOR=symcolor, _Extra=extra), SYMSIZE=symsize, _EXTRA=extra
    ENDIF 
         
    ; If this is the first plot in PS, then we have to make it appear that we have
    ; drawn a plot, even though we haven't.
    IF N_Elements(psnodraw) EQ 1 THEN BEGIN
        !X = afterX
        !Y = afterY
        !P = afterP
    ENDIF
    
    ; Are we producing output? If so, we need to clean up here.
    IF (N_Elements(output) NE 0) && (output NE "") THEN BEGIN
    
        ; Close the PostScript file and create whatever output is needed.
        PS_END, DELETE_PS=delete_ps, $
             BMP=bmp_flag, $
             GIF=gif_flag, $
             JPEG=jpeg_flag, $
             PDF=pdf_flag, $
             PNG=png_flag, $
             TIFF=tiff_flag
         basename = File_Basename(outfilename)
         dirname = File_Dirname(outfilename)
         IF dirname EQ "." THEN CD, CURRENT=dirname
         Print, 'Output File: ' + Filepath(ROOT_DIR=dirname, basename)
    ENDIF
    
    ; Restore the decomposed color state if you can.
    SetDecomposedState, currentState
    
    ; Restore the color table. Can't do this for the Z-buffer or
    ; the snap shot will be incorrect.
    IF (!D.Name NE 'Z') THEN TVLCT, rr, gg, bb
    
    ; Clean up if you are using a layout.
    IF N_Elements(layout) NE 0 THEN !P.Multi = thisMulti
    
END
    
