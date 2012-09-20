; docformat = 'rst'
;
; NAME:
;   cgZImage
;
; PURPOSE:
;   Allows the user to interactively zoom into an image. Program controls are available
;   by right-clicking in the full-sized image window. Zoom factors from 2x to 16x are
;   available. Use the left mouse button to draw a box on the full-sized image to locate
;   the region of the image to zoom.
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
;+
; Allows the user to interactively zoom into an image. Program controls are available
; by right-clicking in the full-sized image window. Zoom factors from 2x to 16x are
; available. Use the left mouse button to draw a box on the full-sized image to locate
; the region of the image to zoom.
;
; :Categories:
;    Graphics
;    
; :Examples:
;    Code examples::
;       IDL> image = cgDemoData(7)
;       IDL> cgZImage, image ; 2D image
;       IDL> image = cgDemoData(16)
;       IDL> cgZImage, image ; True-Color image
;       
; :Author:
;    FANNING SOFTWARE CONSULTING::
;       David W. Fanning 
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: david@idlcoyote.com
;       Coyote's Guide to IDL Programming: http://www.idlcoyote.com
;
; :History:
;     Change History::
;        Written, 20 September 2012 from previous FSC_ZImage program. DWF.
;
; :Copyright:
;     Copyright (c) 2012, Fanning Software Consulting, Inc.
;-

;+
; Event handler for the motion events coming from the zoom window. Find the location
; and value of the image at the cursor location and report it to the status bar in the
; main image window.
;
; :Params:
;     event: in, required, type=structure
;        The event structure passed to the program by the window manager.
;-
PRO cgZImage_ZoomWindow_Events, event

    ; Error handling
    Catch, theError
    IF theError NE 0 THEN BEGIN
        Catch, /CANCEL
        void = Error_Message()
         
        ; Put the info structure back.
        IF N_Elements(info) NE 0 THEN Widget_Control, tlb, Set_UValue=info, /No_Copy
        RETURN
    ENDIF

    ; Get the info structure.
    Widget_Control, event.top, Get_UValue=tlb
    Widget_Control, tlb, Get_UValue=info, /No_Copy
    
    ; Create the proper vectors to locate the cursor in the image.
    xvec = Scale_Vector(Findgen(info.zxsize), info.xrange[0], info.xrange[1])
    yvec = Scale_Vector(Findgen(info.zysize), info.yrange[0], info.yrange[1])
    xloc = Round(xvec[event.x])
    yloc = Round(yvec[event.y])
    
    ; Create the text for the status bar.
    dims = Image_Dimensions(info.image, XSize=xsize, YSize=ysize, TrueIndex=trueindex)
    CASE trueIndex OF
       -1: value = (info.image)[xloc, yloc]
        0: BEGIN
          image = Transpose(info.image, [1,2,0])
          value = [(image[*,*,0])[xloc, yloc], (image[*,*,1])[xloc, yloc], (image[*,*,1])[xloc, yloc]]
          Undefine, image
          END
        1: BEGIN
          image = Transpose(info.image, [0,2,1])
          value = [(image[*,*,0])[xloc, yloc], (image[*,*,1])[xloc, yloc], (image[*,*,1])[xloc, yloc]]
          Undefine, image
          END
        2: BEGIN
          value = [(info.image[*,*,0])[xloc, yloc], (info.image[*,*,1])[xloc, yloc], (info.image[*,*,1])[xloc, yloc]]
          END
    ENDCASE
    
    ; Create the text for the statusbar widget and update the status bar.
    loctext = 'XLoc: ' + Strtrim(xloc,2) + '  YLoc: ' + Strtrim(yloc,2)
    imageType = Size(value, /TNAME)
    IF imageType EQ 'BYTE' THEN value = Fix(value)
    IF N_Elements(value) EQ 1 THEN BEGIN
        valuetext = '  Value: ' + StrTrim(value,2)
    ENDIF ELSE BEGIN
        valuetext = '  RGB Value: (' + StrTrim(value[0],2) + ', ' + $
             StrTrim(value[1],2) + ', ' + StrTrim(value[2],2) + ')'
    ENDELSE
    Widget_Control, info.statusbar, Set_Value=loctext + valuetext
    
    ; Replace the info structure.
    Widget_Control, tlb, Set_UValue=info, /No_Copy
END


;+
; A clean-up routine for the zoom window, if the zoom window is killed.
;
; :Params:
;     zoomID: in, required, type=long
;        The zoom widget identifier
;-
PRO cgZImage_ZoomDied, zoomID

    ; Come here when the zoom window dies. Basically, you 
    ; want to erase the zoom box in the full-size window.
  
    ; Error handling
    Catch, theError
    IF theError NE 0 THEN BEGIN
        Catch, /CANCEL
        void = Error_Message(/Quiet)
         
        ; Put the info structure back.
        IF N_Elements(info) NE 0 THEN Widget_Control, tlb, Set_UValue=info, /No_Copy
        RETURN
    ENDIF

    ; Get the TLB of the full-sized window.
    Widget_Control, zoomID, GET_UVALUE=tlb
    
    ; If that base is gone, disappear!
    IF Widget_Info(tlb, /VALID_ID) EQ 0 THEN RETURN
    
    ; Get the information you need to redisplay the image.
    Widget_Control, tlb, Get_UValue=info, /No_Copy
    
    ; Redisplay the image.
    WSet, info.drawIndex
    cgImage, info.image, $
       BETA=*info.beta, $
       BOTTOM=*info.bottom, $
       CLIP=*info.clip, $
       EXCLUDE=*info.exclude, $
       EXPONENT=*info.exponent, $
       GAMMA=*info.gamma, $
       INTERPOLATE=*info.interpolate, $
       MAXVALUE=*info.max, $
       MEAN=*info.mean, $
       MISSING_COLOR=*info.missing_color, $
       MISSING_INDEX=*info.missing_index, $
       MISSING_VALUE=*info.missing_value, $
       NEGATIVE=*info.negative, $
       MINVALUE=*info.min, $
       MULTIPLIER=*info.multiplier, $
       NCOLORS=*info.ncolors, $
       PALETTE=*info.palette, $
       SCALE=*info.scale, $
       SIGMA=*info.sigma, $
       STRETCH=*info.stretch, $
       TOP=*info.top
       
    WSet, info.pixIndex
    Device, Copy=[0, 0, info.xsize, info.ysize, 0, 0, info.drawIndex]
    
    ; Store the info structure.
    Widget_Control, tlb, Set_UValue=info, /No_Copy

END ; ----------------------------------------------------------------------


;+
; Event handler for changing the rubber-band box color.
;
; :Params:
;     event: in, required, type=structure
;        The event structure passed to the program by the window manager.
;-
PRO cgZImage_BoxColor, event

    ; Come here to change the selector box color.
  
    ; Error handling
    Catch, theError
    IF theError NE 0 THEN BEGIN
        Catch, /CANCEL
        void = Error_Message(/Quiet)
         
        ; Put the info structure back.
        IF N_Elements(info) NE 0 THEN Widget_Control, event.top, Set_UValue=info, /No_Copy
        RETURN
    ENDIF

    ; Get the information you need to redisplaythe image.
    Widget_Control, event.top, Get_UValue=info, /No_Copy
    
    boxcolor = PickColorName(info.boxColor)
    info.boxColor = boxColor
    
    ; Redisplay the image.
    WSet, info.drawIndex
    cgImage, info.image, $      
       BETA=*info.beta, $
       BOTTOM=*info.bottom, $
       CLIP=*info.clip, $
       EXCLUDE=*info.exclude, $
       EXPONENT=*info.exponent, $
       GAMMA=*info.gamma, $
       INTERPOLATE=*info.interpolate, $
       MAXVALUE=*info.max, $
       MEAN=*info.mean, $
       MISSING_COLOR=*info.missing_color, $
       MISSING_INDEX=*info.missing_index, $
       MISSING_VALUE=*info.missing_value, $
       NEGATIVE=*info.negative, $
       MINVALUE=*info.min, $
       MULTIPLIER=*info.multiplier, $
       NCOLORS=*info.ncolors, $
       PALETTE=*info.palette, $
       SCALE=*info.scale, $
       SIGMA=*info.sigma, $
       STRETCH=*info.stretch, $
       TOP=*info.top

    WSet, info.pixIndex
    Device, Copy=[0, 0, info.xsize, info.ysize, 0, 0, info.drawIndex]
    
    ; Store the info structure.
    Widget_Control, event.top, Set_UValue=info, /No_Copy

END ; ----------------------------------------------------------------------


;+
; Event handler for changing the colors the image is displayed in.
;
; :Params:
;     event: in, required, type=structure
;        The event structure passed to the program by the window manager.
;-
PRO cgZImage_LoadColors, event

    ; Come here to load colors or to respond to color loading events.

    ; Error handling
    Catch, theError
    IF theError NE 0 THEN BEGIN
        Catch, /CANCEL
        void = Error_Message(/Quiet)
         
        ; Put the info structure back.
        IF N_Elements(info) NE 0 THEN Widget_Control, event.top, Set_UValue=info, /No_Copy
        RETURN
    ENDIF

    Widget_Control, event.top, Get_UValue=info, /No_Copy
    
    ; What kind of event is this?
    thisEvent = Tag_Names(event, /Structure)
    
    ; Do the right thing.
    CASE thisEvent OF
    
        'WIDGET_BUTTON': BEGIN
            TVLCT, info.r, info.g, info.b, info.bottom
            XColors, Group=event.top, NColors = info.ncolors, $
                Bottom=info.bottom, NotifyID=[event.id, event.top], $
                Title='ZImage Colors (' + StrTrim(info.drawIndex,2) + ')'
            Widget_Control, info.controlID, Map=0
            info.map = 0
            END
            
        'XCOLORS_LOAD':BEGIN
    
                ; Extract the new color table vectors from XCOLORS.
    
            info.r = event.r(info.bottom:info.bottom+info.ncolors-1)
            info.g = event.g(info.bottom:info.bottom+info.ncolors-1)
            info.b = event.b(info.bottom:info.bottom+info.ncolors-1)
    
            ; Redisplay the image.
            WSet, info.drawIndex
            cgImage, info.image, $      
               BETA=*info.beta, $
               BOTTOM=*info.bottom, $
               CLIP=*info.clip, $
               EXCLUDE=*info.exclude, $
               EXPONENT=*info.exponent, $
               GAMMA=*info.gamma, $
               INTERPOLATE=*info.interpolate, $
               MAXVALUE=*info.max, $
               MEAN=*info.mean, $
               MISSING_COLOR=*info.missing_color, $
               MISSING_INDEX=*info.missing_index, $
               MISSING_VALUE=*info.missing_value, $
               NEGATIVE=*info.negative, $
               MINVALUE=*info.min, $
               MULTIPLIER=*info.multiplier, $
               NCOLORS=*info.ncolors, $
               PALETTE=*info.palette, $
               SCALE=*info.scale, $
               SIGMA=*info.sigma, $
               STRETCH=*info.stretch, $
               TOP=*info.top

            WSet, info.pixIndex
            Device, Copy=[0, 0, info.xsize, info.ysize, 0, 0, info.drawIndex]
    
            ; Is a zoom window open? If so, redisplay it as well.
            IF Widget_Info(info.zoomDrawID, /Valid_ID) THEN BEGIN
               WSet, info.zoomWindowID
               IF Ptr_Valid(info.zoomedImage) THEN BEGIN
                  cgImage, *info.zoomedImage, $      
                       BETA=*info.beta, $
                       BOTTOM=*info.bottom, $
                       CLIP=*info.clip, $
                       EXCLUDE=*info.exclude, $
                       EXPONENT=*info.exponent, $
                       GAMMA=*info.gamma, $
                       INTERPOLATE=*info.interpolate, $
                       MAXVALUE=*info.max, $
                       MEAN=*info.mean, $
                       MISSING_COLOR=*info.missing_color, $
                       MISSING_INDEX=*info.missing_index, $
                       MISSING_VALUE=*info.missing_value, $
                       NEGATIVE=*info.negative, $
                       MINVALUE=*info.min, $
                       MULTIPLIER=*info.multiplier, $
                       NCOLORS=*info.ncolors, $
                       PALETTE=*info.palette, $
                       SCALE=*info.scale, $
                       SIGMA=*info.sigma, $
                       STRETCH=*info.stretch, $
                       TOP=*info.top
               ENDIF
            ENDIF
    
            END
    ENDCASE
    Widget_Control, event.top, Set_UValue=info, /No_Copy
END ; ----------------------------------------------------------------------





;+
; Event handler for quiting the program.
;
; :Params:
;     event: in, required, type=structure
;        The event structure passed to the program by the window manager.
;-
PRO cgZImage_Quit, event
    Widget_Control, event.top, /Destroy
END ; ----------------------------------------------------------------------





;+
; The clean-up routine for the program. Come here to release pointers and
; memory.
;
; :Params:
;     tlb: in, required, type=long
;        The identifier of the top-level base of the widget program.
;-
PRO cgZImage_Cleanup, tlb

   ; The purpose of this program is to delete the pixmap window
   ; when the program cgZImage is destroyed. Get the info structure,
   ; which holds the pixmap window index number and delete the window.

    Widget_Control, tlb, Get_UValue=info, /No_Copy
    IF N_Elements(info) NE 0 THEN BEGIN
        WDelete, info.pixIndex
        Ptr_Free, info.zoomedImage
        Ptr_Free, info.beta
        Ptr_Free, info.bottom
        Ptr_Free, info.clip
        Ptr_Free, info.exclude
        Ptr_Free, info.exponent
        Ptr_Free, info.gamma
        Ptr_Free, info.interpolate
        Ptr_Free, info.max
        Ptr_Free, info.mean
        Ptr_Free, info.missing_color
        Ptr_Free, info.missing_index
        Ptr_Free, info.missing_value
        Ptr_Free, info.negative
        Ptr_Free, info.min
        Ptr_Free, info.multiplier
        Ptr_Free, info.ncolors
        Ptr_Free, info.palette
        Ptr_Free, info.scale
        Ptr_Free, info.sigma
        Ptr_Free, info.stretch
        Ptr_Free, info.top
    ENDIF

END ; ----------------------------------------------------------------------


;+
; Event handler for changing the zoom factor.
;
; :Params:
;     event: in, required, type=structure
;        The event structure passed to the program by the window manager.
;-
PRO cgZImage_Factor, event

   ; The purpose of this event handler is to set the zoom factor.

    ; Error handling
    Catch, theError
    IF theError NE 0 THEN BEGIN
        Catch, /CANCEL
        void = Error_Message(/Quiet)
         
        ; Put the info structure back.
        IF N_Elements(info) NE 0 THEN Widget_Control, event.top, Set_UValue=info, /No_Copy
        RETURN
    ENDIF
    
    Widget_Control, event.top, Get_UValue=info, /No_Copy
    Widget_Control, event.id, Get_UValue=factor
    info.zoomfactor = factor[event.index]
    Widget_Control, info.controlID, Map=0
    info.map = 0
    Widget_Control, event.top, Set_UValue=info, /No_Copy
END ; ----------------------------------------------------------------------


;+
; Event handler for handling the rubber-band box events to create
; the zoom window.
;
; :Params:
;     event: in, required, type=structure
;        The event structure passed to the program by the window manager.
;-
PRO cgZImage_DrawEvents, event

   ; This event handler continuously draws and erases the zoom box until it
   ; receives an UP event from the draw widget. Then it turns draw widget
   ; motion events OFF.

    ; Error handling
    Catch, theError
    IF theError NE 0 THEN BEGIN
        Catch, /CANCEL
        void = Error_Message()
         
        ; Turn motion events off.
        Widget_Control, event.id, Draw_Motion_Events=0        
        
        ; Put the info structure back.
        IF N_Elements(info) NE 0 THEN Widget_Control, event.top, Set_UValue=info, /No_Copy
        RETURN
    ENDIF

   ; Get the info structure out of the top-level base.
    Widget_Control, event.top, Get_UValue=info, /No_Copy
    
   ; What type of an event is this?
    possibleEventTypes = [ 'DOWN', 'UP', 'MOTION', 'SCROLL' ]
    thisEvent = possibleEventTypes[event.type]
    buttons = ['NONE', 'LEFT', 'MIDDLE', 'NONE', 'RIGHT']
    
    CASE thisEvent OF
    
       'DOWN': BEGIN
    
       ; Is this the left or right button?
       ; If RIGHT, then map or unmap controls.
       buttonPressed = buttons[event.press]
       IF buttonPressed EQ 'RIGHT' THEN BEGIN
          IF info.map EQ 1 THEN BEGIN
             Widget_Control, info.controlID, Map=0
             info.map = 0
          ENDIF ELSE BEGIN
             Widget_Control, info.controlID, Map=1
             info.map = 1
          ENDELSE
          Widget_Control, event.top, Set_UValue=info, /No_Copy
          RETURN
       ENDIF

      ; Set the static corners of the box to current
      ; cursor location.
      info.xs = event.x
      info.ys = event.y

      ; Turn draw MOTION events ON.
      Widget_Control, event.id, Draw_Motion_Events=1
    
      ENDCASE
    
      'UP': BEGIN
    
       ; Is this the left or right button?
       ; If RIGHT, then do nothing.
       buttonReleased = buttons[event.release]
       IF buttonReleased EQ 'RIGHT' THEN BEGIN
          Widget_Control, event.top, Set_UValue=info, /No_Copy
          RETURN
       ENDIF

      ; If this is an UP event, you need to erase the zoombox, turn motion events OFF, and
      ; draw the "zoomed" plot in both the draw widget and the pixmap.


      ; Turn motion events off.
      Widget_Control, event.id, Draw_Motion_Events=0

      ; Draw the "zoomed" image. Start by getting the LAST zoom
      ; box outline. These are indices into image array.
      event.x = 0 > event.x < (info.xsize - 1)
      event.y = 0 > event.y < (info.ysize - 1)
      x = [info.xs, event.x]
      y = [info.ys, event.y]
      
      ; Make sure the user didn't just click in the window.
      IF info.xs EQ event.x OR info.ys EQ event.y THEN BEGIN
      
          ; Erase the zoombox.
          WSet, info.drawIndex
          TVLCT, info.r, info.g, info.b
          
          ; Copy from the pximap.
          Device, Copy = [0, 0, info.xsize, info.ysize, 0, 0, info.pixIndex]
          Widget_Control, event.top, Set_UValue=info, /No_Copy
          RETURN
          
      ENDIF

      ; Make sure the x and y values are ordered as [min, max].
      IF info.xs GT event.x THEN x = [event.x, info.xs]
      IF info.ys GT event.y THEN y = [event.y, info.ys]
      
      ; Make sure these are in image pixel coordinates, not just
      ; window pixel coordinates.
      xvec = Scale_Vector(Indgen(info.xsize), 0, !D.X_Size-1)
      yvec = Scale_Vector(Indgen(info.ysize), 0, !D.Y_Size-1)
      x = Value_Locate(xvec, x)
      y = Value_Locate(yvec, y)
      info.xrange = x
      info.yrange = y

      ; Set the zoom factor and determine the new X and Y
      ; sizes of the Zoom Window.
      zoomXSize = (x[1] - x[0] + 1) * info.zoomFactor
      zoomYSize = (y[1] - y[0] + 1) * info.zoomFactor
      info.zxsize = zoomXSize
      info.zysize = zoomYSize

      ; Subset the image, and apply the zoom factor to it.
      CASE info.trueIndex OF
          -1: imageSubset = info.image[x[0]:x[1], y[0]:y[1]]
           0: imageSubset = info.image[*, x[0]:x[1], y[0]:y[1]]
           1: imageSubset = info.image[x[0]:x[1], *, y[0]:y[1]]
           2: imageSubset = info.image[x[0]:x[1], y[0]:y[1], *]
      ENDCASE
      
      zoomedImage = FSC_Resize_Image(imageSubset, zoomXSize, zoomYSize, Interp=0)
      IF Ptr_Valid(info.zoomedImage) $
        THEN *info.zoomedImage = zoomedImage $
        ELSE info.zoomedImage = Ptr_New(zoomedImage, /No_Copy)

      ; If the Zoom Window exists, make it the proper size and load
      ; the zoomed image into it. If it does not exists, create it.
      IF Widget_Info(info.zoomDrawID, /Valid_ID) THEN BEGIN

         ; If the new zoomed image needs scroll bars, or the window has
         ; scroll bars, destroy it and recreate it.
         dims = Image_Dimensions(*info.zoomedimage, XSIZE=ixsize, YSIZE=iysize)
         IF (ixsize GT info.maxSize) OR (iysize GT info.maxSize) OR (info.hasScrollBars) THEN BEGIN
         
             ; Get offset positions for the non-existing zoom window.
             Widget_Control, info.zoomDrawID, TLB_Get_Offset=offsets
             xpos = offsets[0] 
             ypos = offsets[1]
             
             Widget_Control, info.zoomDrawID, /Destroy
             
             ; Calculate a window size. Maximum window size is 800.
             dims = Image_Dimensions(*info.zoomedimage, XSIZE=ixsize, YSIZE=iysize)
             aspect = Float(ixsize)/iysize
             MAXSIZE = 800
             IF ixsize GT MAXSIZE OR iysize GT MAXSIZE THEN BEGIN
                 x_scroll_size = MAXSIZE < ixsize
                 y_scroll_size = MAXSIZE < iysize
                 info.hasScrollBars = 1
                 
                 ; Make sure window is not off the display.
                 maxwinsize = MaxWindowSize()
                 IF (xpos + x_scroll_size) GT maxwinsize[0] THEN $
                    xpos = maxwinsize[0] - x_scroll_size
                 IF (ypos + y_scroll_size) GT maxwinsize[1] THEN $
                    ypos = maxwinsize[1] - y_scroll_size
             ENDIF ELSE info.hasScrollBars = 0
             
             ; Zoom window does not exist. Create it.
             zoomtlb = Widget_Base(Title='Zoomed Image', Group=event.top, $
                 XOffset=xpos, YOffset=ypos, KILL_NOTIFY='cgZImage_ZoomDied', $
                 UVALUE=event.top, X_Scroll_Size=x_scroll_size, Y_Scroll_Size=y_scroll_size)
             zoomdraw = Widget_Draw(zoomtlb, XSize=zoomXSize, YSize=zoomYSize, $
                /MOTION_EVENTS, Event_Pro='cgZImage_ZoomWindow_Events')
             Widget_Control, zoomtlb, /Realize
             Widget_Control, zoomdraw, Get_Value=windowID
             info.zoomDrawID = zoomdraw
             info.zoomWindowID = windowID
             WSet, windowID
             IF Ptr_Valid(info.zoomedImage) THEN BEGIN
                cgImage, *info.zoomedImage, $      
                   BETA=*info.beta, $
                   BOTTOM=*info.bottom, $
                   CLIP=*info.clip, $
                   EXCLUDE=*info.exclude, $
                   EXPONENT=*info.exponent, $
                   GAMMA=*info.gamma, $
                   INTERPOLATE=*info.interpolate, $
                   MAXVALUE=*info.max, $
                   MEAN=*info.mean, $
                   MISSING_COLOR=*info.missing_color, $
                   MISSING_INDEX=*info.missing_index, $
                   MISSING_VALUE=*info.missing_value, $
                   NEGATIVE=*info.negative, $
                   MINVALUE=*info.min, $
                   MULTIPLIER=*info.multiplier, $
                   NCOLORS=*info.ncolors, $
                   PALETTE=*info.palette, $
                   SCALE=*info.scale, $
                   SIGMA=*info.sigma, $
                   STRETCH=*info.stretch, $
                   TOP=*info.top
             ENDIF
     
          ENDIF ELSE BEGIN
         
         ; Zoomed window exists. Make it correct size and load image.
         Widget_Control, info.zoomDrawID, XSize=zoomXSize, YSize=zoomYSize
         WSet, info.zoomWindowID
         IF Ptr_Valid(info.zoomedImage) THEN BEGIN
            cgImage, *info.zoomedImage, $      
               BETA=*info.beta, $
               BOTTOM=*info.bottom, $
               CLIP=*info.clip, $
               EXCLUDE=*info.exclude, $
               EXPONENT=*info.exponent, $
               GAMMA=*info.gamma, $
               INTERPOLATE=*info.interpolate, $
               MAXVALUE=*info.max, $
               MEAN=*info.mean, $
               MISSING_COLOR=*info.missing_color, $
               MISSING_INDEX=*info.missing_index, $
               MISSING_VALUE=*info.missing_value, $
               NEGATIVE=*info.negative, $
               MINVALUE=*info.min, $
               MULTIPLIER=*info.multiplier, $
               NCOLORS=*info.ncolors, $
               PALETTE=*info.palette, $
               SCALE=*info.scale, $
               SIGMA=*info.sigma, $
               STRETCH=*info.stretch, $
               TOP=*info.top
         ENDIF
         
         ENDELSE
      ENDIF ELSE BEGIN

         ; Get offset positions for the non-existing zoom window.
         Widget_Control, event.top, TLB_Get_Size=sizes, TLB_Get_Offset=offsets
         xpos = sizes[0] + offsets[0] + 20
         ypos = offsets[1] + 40
         
         ; Calculate a window size. Maximum window size is 800.
         dims = Image_Dimensions(*info.zoomedimage, XSIZE=ixsize, YSIZE=iysize)
         aspect = Float(ixsize)/iysize
         MAXSIZE = 800
         IF ixsize GT MAXSIZE OR iysize GT MAXSIZE THEN BEGIN
             x_scroll_size = MAXSIZE < ixsize
             y_scroll_size = MAXSIZE < iysize
             info.hasScrollBars = 1
                 
             ; Make sure window is not off the display.
             maxwinsize = MaxWindowSize()
             IF (xpos + x_scroll_size) GT maxwinsize[0] THEN $
                xpos = maxwinsize[0] - x_scroll_size
             IF (ypos + y_scroll_size) GT maxwinsize[1] THEN $
                ypos = maxwinsize[1] - y_scroll_size
         ENDIF ELSE info.hasScrollBars = 0
         
         ; Zoom window does not exist. Create it.
         zoomtlb = Widget_Base(Title='Zoomed Image', Group=event.top, $
             XOffset=xpos, YOffset=ypos, KILL_NOTIFY='cgZImage_ZoomDied', $
             UVALUE=event.top, X_Scroll_Size=x_scroll_size, Y_Scroll_Size=y_scroll_size)
         zoomdraw = Widget_Draw(zoomtlb, XSize=zoomXSize, YSize=zoomYSize, $
                /MOTION_EVENTS, Event_Pro='cgZImage_ZoomWindow_Events')
         Widget_Control, zoomtlb, /Realize
         Widget_Control, zoomdraw, Get_Value=windowID
         info.zoomDrawID = zoomdraw
         info.zoomWindowID = windowID
         WSet, windowID
         IF Ptr_Valid(info.zoomedImage) THEN BEGIN
            cgImage, *info.zoomedImage, $
               BETA=*info.beta, $
               BOTTOM=*info.bottom, $
               CLIP=*info.clip, $
               EXCLUDE=*info.exclude, $
               EXPONENT=*info.exponent, $
               GAMMA=*info.gamma, $
               INTERPOLATE=*info.interpolate, $
               MAXVALUE=*info.max, $
               MEAN=*info.mean, $
               MISSING_COLOR=*info.missing_color, $
               MISSING_INDEX=*info.missing_index, $
               MISSING_VALUE=*info.missing_value, $
               NEGATIVE=*info.negative, $
               MINVALUE=*info.min, $
               MULTIPLIER=*info.multiplier, $
               NCOLORS=*info.ncolors, $
               PALETTE=*info.palette, $
               SCALE=*info.scale, $
               SIGMA=*info.sigma, $
               STRETCH=*info.stretch, $
               TOP=*info.top
            
         ENDIF
         
      ENDELSE

      ; If the controls were mapped, unmap them.
      IF info.map EQ 1 THEN BEGIN
          Widget_Control, info.controlID, Map=0
          info.map = 0
      ENDIF
    
      ENDCASE

    'MOTION': BEGIN

    ; Most of the action in this event handler occurs here while we are waiting
    ; for an UP event to occur. As long as we don't get it, keep erasing the
    ; old zoom box and drawing a new one.

    ; Erase the old zoom box.
    WSet, info.drawIndex
    TVLCT, info.r, info.g, info.b, *info.bottom
    Device, Copy = [0, 0, info.xsize, info.ysize, 0, 0, info.pixIndex]

    ; Update the dynamic corner of the zoom box to the current cursor location.
    info.xd = event.x
    info.yd = event.y

    ; Draw the zoom box. 
    Device, Get_Decomposed=theState
    Device, Decomposed=1
    PlotS, [info.xs, info.xs, info.xd, info.xd, info.xs], $
       [info.ys, info.yd, info.yd, info.ys, info.ys], $
       /Device, Color=cgColor(info.boxcolor)
    Device, Decomposed=theState
       
    ENDCASE

ENDCASE

   ; Put the info structure back into its storage location.

Widget_Control, event.top, Set_UValue=info, /No_Copy
END ; ----------------------------------------------------------------------


;+
; Allows the user to interactively zoom into an image. Program controls are available
; by right-clicking in the full-sized image window. Zoom factors from 2x to 16x are
; available. Use the left mouse button to draw a box on the full-sized image to locate
; the region of the image to zoom.
;
; :Params:
;    image: in, required, type=any
;        A 2D or true-color image of any normal data type. If not a BYTE array,
;        cgImage keywords for proper image scaling must be used to provide image
;        scaling parameters.
;       
; :Keywords:
;    beta: in, optional, type=float, default=3.0
;         The beta factor in a Hyperpolic Sine stretch. Available only with 2D images.
;    bottom: in, optional, type=integer, default=0
;         If the SCALE keyword is set, the image is scaled before display so that all 
;         displayed pixels have values greater than or equal to BOTTOM and less than 
;         or equal to TOP. Available only with 2D images.
;    boxcolor: in, optional, type=string, default='red'
;         The name of the color of the rubber-band selection box.
;    clip: in, optional, type=float, default=2
;         A number between 0 and 50 that indicates the percentage of pixels to clip
;         off either end of the image histogram before performing a linear stretch.
;         Available only with 2D images.
;    exclude: in, optional, type=numeric
;         The value to exclude in a standard deviation stretch.
;    exponent: in, optional, type=float, default=4.0
;         The logarithm exponent in a logarithmic stretch. Available only with 2D images.
;    gamma: in, optional, type=float, default=1.5
;         The gamma factor in a gamma stretch. Available only with 2D images.
;    group_leader: in, optional, type=long
;         The widget identifier of the group leader for this program. When the group leader
;         dies, this program will be destroyed, too.
;    interpolate: in, optional, type=boolean, default=0
;         Set this keyword to interpolate with bilinear interpolation the display image as it 
;         is sized to its final position in the display window. Interpolation will potentially 
;         create image values that do not exist in the original image. The default is to do no
;         interpolation, so that image values to not change upon resizing. Interpolation can
;         result in smoother looking final images.
;    maxvalue: in, optional, type=varies
;         If this value is defined, the data is linearly scaled between MINVALUE
;         and MAXVALUE. MAXVALUE is set to MAX(image) by default. Setting this 
;         keyword to a value automatically sets `SCALE` to 1. If the maximum value of the 
;         image is greater than 255, this keyword is defined and SCALE=1.
;    mean: in, optional, type=float, default=0.5
;         The mean factor in a logarithmic stretch. Available only with 2D images.
;    minvalue: in, optional, type=varies
;         If this value is defined, the data is linearly scaled between MINVALUE
;         and `MAXVALUE`. MINVALUE is set to MIN(image) by default. Setting this 
;         keyword to a value automatically sets SCALE=1. If the minimum value of the 
;         image is less than 0, this keyword is defined and SCALE=1.
;    missing_color: in, optional, type=string, default='white'
;         The color name of the missing value. Available only with 2D images.
;    missing_index: in, optional, type=integer, default=255 
;         The index of the missing color in the final byte scaled image. Available only with 2D images.
;    missing_value: in, optional, type=integer
;         The number that represents the missing value in the image. Available only with 2D images.
;    multiplier: in, optional, type=float
;         The multiplication factor in a standard deviation stretch. The standard deviation
;         is multiplied by this factor to produce the thresholds for a linear stretch.
;    ncolors: in, optional, type=integer, default=256
;         If this keyword is supplied, the `TOP` keyword is ignored and the TOP keyword 
;         is set equal to  NCOLORS-1. This keyword is provided to make cgImage easier 
;         to use with the color-loading programs such as cgLOADCT::
;
;              cgLoadCT, 5, NColors=100, Bottom=100
;              cgImage, image, NColors=100, Bottom=100
;                  
;         Setting this keyword to a value automatically sets SCALE=1. Available only with 2D images.
;    negative: in, optional, type=boolean, default=0
;         Set this keyword if you want to display the image with a negative or reverse stretch.
;         Available only with 2D images.
;    palette: in, optional, type=byte
;         Set this keyword to a 3x256 or 256x3 byte array containing the RGB color 
;         vectors to be loaded before the image is displayed. Such vectors can be 
;         obtained, for example, from cgLoadCT with the RGB_TABLE keyword::
;               
;                cgLoadCT, 4, /BREWER, /REVERSE, RGB_TABLE=palette
;                cgImage, cgDemoData(7), PALETTE=palette
;    scale: in, optional, type=boolean, default=0
;         Set this keyword to byte scale the image before display. If this keyword is not set, 
;         the image is not scaled before display. This keyword will be set automatically by using
;         any of the keywords normally associated with byte scaling an image. Available only with 
;         2D images. If set, STRETCH is set to 1, unless it is set to another value.
;    stretch: in, optional, type=integer/string, default=1
;         The type of scaling performed prior to display. May be specified as a number 
;         or as a string (e.g, 3 or "Log"). Available only with 2D images.
;
;           Number   Type of Stretch
;             0         None           No scaling whatsoever is done.
;             1         Linear         scaled = BytScl(image, MIN=minValue, MAX=maxValue)
;             2         Clip           A histogram stretch, with a percentage of pixels clipped at both the top and bottom
;             3         Gamma          scaled = GmaScl(image, MIN=minValue, MAX=maxValue, Gamma=gamma)
;             4         Log            scaled = LogScl(image, MIN=minValue, MAX=maxValue, Mean=mean, Exponent=exponent)
;             5         Asinh          scaled = AsinhScl(image, MIN=minValue, MAX=maxValue, Beta=beta)
;             6         SquareRoot     A linear stretch of the square root histogram of the image values.
;             7         Equalization   A linear stretch of the histogram equalized image histogram.
;             8         Gaussian       A Gaussian normal function is applied to the image histogram.
;             9         MODIS          Scaling done in the differential manner of the MODIS Rapid Response Team
;                                      and implemented in the Coyote Library routine ScaleModis.
;    sigma: in, optional, type=float, default=1.0
;         The sigma scale factor in a Gaussian stretch. Available only with 2D images.
;    title: in, optional, type=string, default=""
;         Set this keyword to the title of the plot window.
;    top: in, optional, type=integer, default=255
;         If the SCALE keyword is set, the image is scaled before display so that all 
;         displayed pixels have values greater than or equal to BOTTOM and less than 
;         or equal to TOP. Available only with 2D images.
;-
PRO cgZImage, image, $
   BETA=beta, $
   BOTTOM=bottom, $
   BOXCOLOR=sboxcolor, $
   CLIP=clip, $
   EXCLUDE=exclude, $
   EXPONENT=exponent, $
   GAMMA=gamma, $
   GROUP_LEADER=group_leader, $
   INTERPOLATE=interpolate, $
   MAXVALUE=max, $
   MEAN=mean, $
   MISSING_COLOR=missing_color, $
   MISSING_INDEX=missing_index, $
   MISSING_VALUE=missing_value, $
   NEGATIVE=negative, $
   MINVALUE=min, $
   MULTIPLIER=multiplier, $
   NCOLORS=ncolors, $
   PALETTE=palette, $
   SCALE=scale, $
   SIGMA=sigma, $
   STRETCH=stretch, $
   TITLE=title, $
   TOP=top
    
    Compile_Opt idl2
    
    ; Error handling
    Catch, theError
    IF theError NE 0 THEN BEGIN
        Catch, /CANCEL
        void = Error_Message()
        RETURN
    ENDIF

    ; Was an image passed into the procedure?
    ; If not, find one in the IDL examples/data directory.
    IF N_Params() EQ 0 THEN BEGIN
       image = ImageSelect(FILENAME='marsglobe.jpg', CANCEL=cancelled, /EXAMPLES)
       IF cancelled THEN RETURN
    ENDIF
    
    ; Just make sure nothing undefined got passed in.
    IF N_Elements(image) EQ 0 THEN Message, 'An image parameter is required.

    ; Check for keywords. 
    IF N_Elements(sboxcolor) EQ 0 THEN boxcolor = 'red8' ELSE boxcolor = sboxcolor
    IF N_Elements(factor) EQ 0 THEN factor = 4
    nointerp = Keyword_Set(nointerp)
    
    ; Get image size.
    dims = Image_Dimensions(image, XSize=ixsize, YSize=iysize, $
        XIndex=xindex, YIndex=yindex, TrueIndex=trueindex)
    
    ; Calculate a window size. Maximum window size is 600.
     aspect = Float(ixsize)/iysize
     MAXSIZE = 600
     IF ixsize GT MAXSIZE OR iysize GT MAXSIZE THEN BEGIN
         IF ixsize NE iysize THEN BEGIN
            aspect = Float(iysize) / ixsize
            IF aspect LT 1 THEN BEGIN
               xsize = MAXSIZE
               ysize = (MAXSIZE * aspect) < MAXSIZE
            ENDIF ELSE BEGIN
               ysize = MAXSIZE
               xsize = (MAXSIZE / aspect) < MAXSIZE
            ENDELSE
         ENDIF ELSE BEGIN
            ysize = MAXSIZE
            xsize = MAXSIZE
         ENDELSE
     ENDIF ELSE BEGIN
        xsize = ixsize
        ysize = iysize
     ENDELSE

     IF N_Elements(beta) EQ 0 THEN  beta = Ptr_New(/Allocate_Heap) ELSE beta = Ptr_New(beta)
     IF N_Elements(bottom) EQ 0 THEN  bottom = Ptr_New(/Allocate_Heap) ELSE bottom = Ptr_New(bottom)
     IF N_Elements(clip) EQ 0 THEN  clip = Ptr_New(/Allocate_Heap) ELSE clip = Ptr_New(clip)
     IF N_Elements(exclude) EQ 0 THEN  exclude = Ptr_New(/Allocate_Heap) ELSE exclude = Ptr_New(exclude)
     IF N_Elements(exponent) EQ 0 THEN  exponent = Ptr_New(/Allocate_Heap) ELSE exponent = Ptr_New(exponent)
     IF N_Elements(gamma) EQ 0 THEN  gamma = Ptr_New(/Allocate_Heap) ELSE gamma = Ptr_New(gamma)
     IF N_Elements(interpolate) EQ 0 THEN  interpolate = Ptr_New(/Allocate_Heap) ELSE interpolate = Ptr_New(interpolate)
     IF N_Elements(max) EQ 0 THEN  max = Ptr_New(/Allocate_Heap) ELSE max = Ptr_New(max)
     IF N_Elements(mean) EQ 0 THEN  mean = Ptr_New(/Allocate_Heap) ELSE mean = Ptr_New(mean)
     IF N_Elements(missing_color) EQ 0 THEN  missing_color = Ptr_New(/Allocate_Heap) ELSE missing_color = Ptr_New(missing_color)
     IF N_Elements(missing_index) EQ 0 THEN  missing_index = Ptr_New(/Allocate_Heap) ELSE missing_index = Ptr_New(missing_index)
     IF N_Elements(missing_value) EQ 0 THEN  missing_value = Ptr_New(/Allocate_Heap) ELSE missing_value = Ptr_New(missing_value)
     IF N_Elements(negative) EQ 0 THEN  negative = Ptr_New(/Allocate_Heap) ELSE negative = Ptr_New(negative)
     IF N_Elements(min) EQ 0 THEN  min = Ptr_New(/Allocate_Heap) ELSE min = Ptr_New(min)
     IF N_Elements(multiplier) EQ 0 THEN  multiplier = Ptr_New(/Allocate_Heap) ELSE multiplier = Ptr_New(multiplier)
     IF N_Elements(ncolors) EQ 0 THEN  ncolors = Ptr_New(/Allocate_Heap) ELSE ncolors = Ptr_New(ncolors)
     IF N_Elements(palette) EQ 0 THEN  palette = Ptr_New(/Allocate_Heap) ELSE palette = Ptr_New(palette)
     IF N_Elements(scale) EQ 0 THEN  scale = Ptr_New(/Allocate_Heap) ELSE scale = Ptr_New(scale)
     IF N_Elements(sigma) EQ 0 THEN  sigma = Ptr_New(/Allocate_Heap) ELSE sigma = Ptr_New(sigma)
     IF N_Elements(stretch) EQ 0 THEN  stretch = Ptr_New(/Allocate_Heap) ELSE stretch = Ptr_New(stretch)
     IF N_Elements(top) EQ 0 THEN  top = Ptr_New(/Allocate_Heap) ELSE top = Ptr_New(top)
    
    ; Create a top-level base for this program. No resizing of this base.
    tlb = Widget_Base(TLB_Frame_Attr=1, TITLE=title)

    ; Create two bases. One for controls and the other for the
    ; draw widget. Leave the control base unmapped for now.
    controlID = Widget_Base(tlb, Map=0, Column=1)
    factorString = ['2x', '3x', '4x', '5x', '6x', '7x', '8x', '12x', '16x']
    factors = [Indgen(7) + 2, 12, 16]
    zoomfactor = Widget_DropList(controlID, Value=factorString, $
       Event_Pro='cgZImage_Factor', UValue=factors, Title='Zoom Factor')
    IF trueindex EQ -1 THEN BEGIN
        colors = Widget_Button(controlID, Value='Load Image Colors', Event_Pro='cgZImage_LoadColors')
    ENDIF
    void = Widget_Button(controlID, Value='Change Selection Box Color', Event_Pro='cgZImage_BoxColor')
    quitter = Widget_Button(controlID, Value='Exit Program', $
       Event_Pro='cgZImage_Quit')
    
    drawbase = Widget_Base(tlb, Map=1, Column=1)
    draw = Widget_Draw(drawbase, XSize=xsize, YSize=ysize, $
       Button_Events=1, Event_Pro='cgZImage_DrawEvents')

    statusbar = Widget_Label(drawbase, Value="Ready for Zooming", SCR_XSIZE=xsize, /Sunken_Frame)
    
    ; Realize the program.
    Widget_Control, tlb, /Realize
    
    ; Set the initial default zoom factor.
    Widget_Control, zoomfactor, SET_DROPLIST_SELECT=2
    
    ; Get the window index number of the draw widget.
    ; Make the draw widget the current graphics window
    ; and display the image in it.
    Widget_Control, draw, Get_Value=drawIndex
    WSet, drawIndex
    cgImage, image, $
       BETA=*beta, $
       BOTTOM=*bottom, $
       CLIP=*clip, $
       EXCLUDE=*exclude, $
       EXPONENT=*exponent, $
       GAMMA=*gamma, $
       INTERPOLATE=*interpolate, $
       MAXVALUE=*max, $
       MEAN=*mean, $
       MISSING_COLOR=*missing_color, $
       MISSING_INDEX=*missing_index, $
       MISSING_VALUE=*missing_value, $
       NEGATIVE=*negative, $
       MINVALUE=*min, $
       MULTIPLIER=*multiplier, $
       NCOLORS=*ncolors, $
       PALETTE=*palette, $
       SCALE=*scale, $
       SIGMA=*sigma, $
       STRETCH=*stretch, $
       TOP=*top

    ; Set the title of the window.
    IF N_Elements(title) EQ 0 THEN BEGIN
        Widget_Control, tlb, TLB_Set_Title='Full Size Image (' + StrTrim(drawIndex,2) + ') -- ' + $
           'Right Click for Controls.'
    ENDIF

    ; Create a pixmap window the same size as the draw widget window.
    ; Store its window index number in a local variable. Display the
    ; image you just put in the draw widget in the pixmap window.
    Window, /Free, XSize=xsize, YSize=ysize, /Pixmap
    pixIndex = !D.Window
    cgImage, image, $
       BETA=*beta, $
       BOTTOM=*bottom, $
       CLIP=*clip, $
       EXCLUDE=*exclude, $
       EXPONENT=*exponent, $
       GAMMA=*gamma, $
       INTERPOLATE=*interpolate, $
       MAXVALUE=*max, $
       MEAN=*mean, $
       MISSING_COLOR=*missing_color, $
       MISSING_INDEX=*missing_index, $
       MISSING_VALUE=*missing_value, $
       NEGATIVE=*negative, $
       MINVALUE=*min, $
       MULTIPLIER=*multiplier, $
       NCOLORS=*ncolors, $
       PALETTE=*palette, $
       SCALE=*scale, $
       SIGMA=*sigma, $
       STRETCH=*stretch, $
       TOP=*top

   ; Get color vectors for this application.
   TVLCT, r, g, b, /Get

   ; Create an info structure to hold information required by the program.
   
    info = { $
       image:image, $               ; The original image.
       zoomedimage:Ptr_New(), $     ; The scaled and resized subimage.
       xsize:ixsize, $              ; The x size of the image.
       ysize:iysize, $              ; The y size of the image.
       drawIndex:drawIndex, $       ; The draw window index number.
       pixIndex:pixIndex, $         ; The pixmap window index number.
       boxcolor:boxcolor, $         ; The name of the drawing color.
       xs:0, $                      ; X static corner of the zoom box.
       ys:0, $                      ; Y static corner of the zoom box.
       xd:0, $                      ; X dynamic corner of the zoom box.
       yd:0, $                      ; Y dynamic corner of the zoom box.
       zoomDrawID:-1L, $            ; Zoomed image draw widget ID.
       zoomWindowID:-1, $           ; Zoomed image window index number.
       statusbar:statusbar, $       ; The statusbar identifier.
       r:r, $                       ; The red color vector.
       g:g, $                       ; The green color vector.
       b:b, $                       ; The blue color vector.
       beta:beta, $
       bottom:bottom, $
       clip:clip, $
       exclude:exclude, $
       exponent:exponent, $
       gamma:gamma, $
       interpolate:interpolate, $
       max:max, $
       mean:mean, $
       missing_color:missing_color, $
       missing_index:missing_index, $
       missing_value:missing_value, $
       negative:negative, $
       min:min, $
       multiplier:multiplier, $
       ncolors:ncolors, $
       palette:palette, $
       scale:scale, $
       sigma:sigma, $
       stretch:stretch, $
       top:top, $
       xrange: [0,ixsize], $
       yrange: [0,iysize], $
       zxsize: 0, $
       zysize: 0, $
       zoomfactor:factor, $         ; The initial zoom factor.
       map:0, $                     ; A flag to tell if the controls are mapped.
       xindex:xindex, $             ; The X size index.
       yindex:yindex, $             ; The Y size index.
       trueIndex:trueIndex, $       ; The "true-color" index. 0 if image is 2D.
       MAXSIZE:800, $               ; The maximum window size.
       hasScrollBars: 0, $          ; A flag indicating the zoom window has scroll bars.
       controlID:controlID}         ; The identifier of the control base to map.

    ; Store the info structure in the user value of the top-level base.
    Widget_Control, tlb, Set_UValue=info, /No_Copy

    ; Register this program and set up the event loop.
    XManager, 'cgzimage', tlb, Cleanup='cgZImage_Cleanup', Group_Leader=group_leader, /No_Block
    
END ; ----------------------------------------------------------------------


