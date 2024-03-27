#tag Class
Protected Class PlotArea
Inherits Canvas
	#tag Event
		Sub Paint(g As Graphics, areas() As REALbasic.Rect)
		  PlotGraph(g)
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub drawBars(g as Graphics)
		  if data <> nil and data.Ubound <> -1 then
		    Dim barCount As Integer = Data.Ubound + 1
		    
		    // Take the length of the line
		    dim w as Double = g.Width - leftMargin - rightMargin
		    dim h as double = g.Height - topMargin - bottomMargin
		    
		    //divide the line into nbins.
		    Dim nbins as integer = data.Ubound+1  // The number of bins
		    dim binWidth as double = w / nbins
		    //dim halfBinWidth as double = binWidth / 2
		    
		    dim gap as double = (binWidth *.1) / 2 // make a small gap between bars.
		    dim scaledWidth as double = binWidth * .9 // .05 + .9 + .05 = 1
		    
		    dim maxDataValue as double = Max(data)
		    dim minDataValue as double = 0 //Min(data)
		    dim barYScale as double = h / (maxDataValue-minDataValue)
		    
		    dim y as double = g.height - bottomMargin
		    For bin As Integer = 0 To nbins - 1
		      
		      Dim x As double = leftMargin + (bin * w / nbins) ' Adjust the starting point to consider the padding
		      
		      Dim barHeight As double = (data(bin)-minDataValue)*barYScale
		      if BarColors <> nil and BarColors.Ubound <> -1 then
		        g.ForeColor = BarColors(BarColors.Ubound mod bin)
		      else
		        g.ForeColor = BarColor
		      end if
		      g.FillRect(x+gap, y, scaledWidth, -barHeight) ' Adjust startX for the position of the current major tick
		      g.ForeColor = color.DarkGray
		      g.drawRect(x+gap, y, scaledWidth, -barHeight) ' Adjust startX for the position of the current major tick
		      
		    next
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawHorizontalAxis(g as Graphics)
		  ' Start x-axis from leftMargin pixels from the left edge
		  g.ForeColor = AxisColor
		  g.DrawLine(leftMargin, g.Height - bottomMargin, g.Width - rightMargin, g.Height - bottomMargin) 
		  
		  // Take the length of the line
		  dim w as Double = g.Width - leftMargin - rightMargin
		  
		  //divide the line into nbins.
		  Dim nbins as integer = data.Ubound+1  // The number of bins
		  
		  Dim labelWidth as Integer
		  dim halfBinWidth as double = w / nbins / 2
		  if PType <> PlotType.Bar then
		    halfBinWidth = 0
		  end if
		  
		  If ShowTicks Then
		    
		    For bin As Integer = 0 To nbins - 1
		      
		      Dim x As double = leftMargin + (bin * w / nbins) ' Adjust the starting point to consider the padding
		      
		      labelWidth = StringWidth(g, Str(bin))
		      g.DrawString(Str(bin), x - labelWidth / 2 + halfBinWidth, g.Height - bottomMargin + g.TextHeight)
		      
		      g.DrawLine(x, g.Height - bottomMargin+tickSize, x, g.Height-bottomMargin)
		    next
		    
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawLines(g as Graphics)
		  if data <> nil and data.Ubound <> -1 then
		    Dim barCount As Integer = Data.Ubound + 1
		    
		    // Take the length of the line
		    dim w as Double = g.Width - leftMargin - rightMargin
		    dim h as double = g.Height - topMargin - bottomMargin
		    
		    //divide the line into nbins.
		    Dim nbins as integer = data.Ubound+1  // The number of bins
		    dim binWidth as double = w / nbins
		    
		    dim maxDataValue as double = Max(data)
		    dim minDataValue as double = 0 //Min(data)
		    dim YScale as double = h / (maxDataValue-minDataValue+1)
		    
		    For bin As Integer = 0 To nbins - 2
		      
		      Dim x1 As double = leftMargin + (bin * w / nbins) ' Adjust the starting point to consider the padding
		      Dim y1 As double = (data(bin)-minDataValue)*YScale
		      
		      Dim x2 As double = leftMargin + ((bin+1) * w / nbins) ' Adjust the starting point to consider the padding
		      Dim y2 As double = (data(bin+1)-minDataValue)*YScale
		      
		      y1 = h - y1 + topMargin
		      y2 = h - y2 + topMargin
		      
		      if BarColors <> nil and BarColors.Ubound <> -1 then
		        g.ForeColor = BarColors(bin)
		      else
		        g.ForeColor = BarColor
		      end if
		      
		      PlotPointCircle(g,x1,y1,3)
		      g.DrawLine(x1,y1,x2,y2)
		      PlotPointCircle(g,x2,y2,3)
		      
		    next
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawPoints(g as Graphics)
		  if data <> nil and data.Ubound <> -1 then
		    
		    //Points in the data are organized in pairs of x,y 
		    Dim barCount As Integer = Data.Ubound + 1
		    barCount = barCount \ 2  // Therefore should also be even.
		    
		    // Take the length of the line
		    dim w as Double = g.Width - leftMargin - rightMargin
		    dim h as double = g.Height - topMargin - bottomMargin
		    
		    //divide the line into nbins.
		    Dim nbins as integer = data.Ubound+1  // The number of bins
		    dim binWidth as double = w / nbins
		    
		    dim minX, maxX, minY, maxY as double
		    
		    minX = data(0)
		    minY = data(1)
		    maxX = minX
		    maxY = minY
		    for p as integer = 0 to data.Ubound step 2
		      if data(p) < minX then 
		        minX = data(p) 
		      end if
		      if data(p) > maxX then 
		        maxX = data(p) 
		      end if
		      if data(p+1) < minY then 
		        minY = data(p+1) 
		      end if
		      if data(p+1) > maxY then 
		        maxY = data(p+1) 
		      end if
		    next
		    
		    dim XScale, YScale as double
		    XScale = w / (maxX-minX+1)
		    YScale = h / (maxY-minY+1)
		    
		    
		    for p as integer = 0 to data.Ubound step 2
		      
		      dim x as double = data(p)
		      dim y as double = data(p+1)
		      
		      x = x - minX
		      y = y - MinY
		      x = x * XScale
		      y = y * YScale
		      
		      x = x + leftMargin
		      y = y + topMargin
		      
		      y = h - y  // because 0 is at the top not the bottom. 
		      
		      if BarColors <> nil and BarColors.Ubound <> -1 then
		        g.ForeColor = BarColors(9 mod (p\2))
		      else
		        g.ForeColor = BarColor
		      end if
		      
		      PlotPointCircle(g,x,y,3)
		      
		    next
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub drawVerticalAxis(g as Graphics)
		  ' Start y-axis from bottomMargin pixels from the bottom edge
		  g.ForeColor = AxisColor
		  g.DrawLine(leftMargin, g.Height - bottomMargin, leftMargin, topMargin)
		  
		  ' Take the height of the axis
		  Dim h As Double = g.Height - topMargin - bottomMargin
		  
		  ' Determine the maximum value in the data array
		  Dim maxValue As Double = Max(data)
		  dim numTicks as Integer = 10
		  
		  ' Calculate the number of ticks based on a desired interval
		  Dim tickInterval As Double = maxValue / numTicks
		  Dim tickValue As Double = 0
		  Dim labelPadding as double = 2
		  
		  ' Draw ticks and labels
		  For i As Integer = 0 To numTicks
		    Dim y As Double = g.Height - bottomMargin - (i * h / numTicks)
		    
		    ' Draw tick mark
		    g.DrawLine(leftMargin - tickSize, y, leftMargin, y)
		    
		    ' Draw label
		    g.DrawString(Format(tickValue, "0.0"), leftMargin - tickSize - labelPadding - StringWidth(g, Format(tickValue, "0.0")), y + g.TextHeight /4)
		    
		    ' Increment tick value
		    tickValue = tickValue + tickInterval
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Max(data() as integer) As integer
		  if data<> nil and data.Ubound <> -1 then
		    dim m as integer
		    m = data(0)
		    for i as integer = 0 to data.Ubound
		      if data(i) > m then m = data(i)
		    next
		    return m
		  else
		    Raise New OutOfBoundsException
		  end if
		  //Not reached
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Min(data() as integer) As integer
		  if data<> nil and data.Ubound <> -1 then
		    dim m as integer
		    m = data(0)
		    for i as integer = 0 to data.Ubound
		      if data(i) < m then m = data(i)
		    next
		    return m
		  else
		    Raise New OutOfBoundsException
		  end if
		  //Not reached
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Plot(userData() as integer, AxisColor as color, BarColors() as color, ptype as PlotType)
		  data = userData
		  me.AxisColor = AxisColor
		  me.BarColors = BarColors
		  me.PType = ptype
		  me.Refresh
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Plot(userData() as integer, AxisColor as color, BarColor as color, ptype as PlotType)
		  data = userData
		  me.AxisColor = AxisColor
		  me.BarColor = BarColor
		  me.PType = ptype
		  me.Refresh
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PlotGraph(g as graphics)
		  If Data <> Nil And Data.Ubound <> -1 Then
		    If ShowAxis Then
		      drawHorizontalAxis(g)
		      drawVerticalAxis(g)
		    end if
		    select case PType
		    case PlotType.Bar
		      drawBars(g)
		    case PlotType.Line
		      drawLines(g)
		    case PlotType.Scatter
		      drawPoints(g)
		    end select
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PlotPointCircle(g as Graphics, x as double, y as Double, r as Double)
		  g.ForeColor = color.red
		  g.FillOval(x-r,y-2, 2*r, 2*r)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StringWidth(g as Graphics, text as String) As integer
		  Dim tempBitmap As New Picture(1, 1)
		  Dim tempGraphics As Graphics = tempBitmap.Graphics
		  Dim width As Integer = tempGraphics.StringWidth(text)
		  
		  tempGraphics = Nil
		  tempBitmap = Nil
		  
		  Return width
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		AxisColor As Color = color.red
	#tag EndProperty

	#tag Property, Flags = &h0
		BarColor As Color = color.blue
	#tag EndProperty

	#tag Property, Flags = &h0
		BarColors(-1) As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private data() As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		PType As PlotType = PlotType.Line
	#tag EndProperty

	#tag Property, Flags = &h0
		ShowAxis As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		ShowTicks As Boolean = True
	#tag EndProperty


	#tag Constant, Name = bottomMargin, Type = Double, Dynamic = False, Default = \"20", Scope = Public
	#tag EndConstant

	#tag Constant, Name = leftMargin, Type = Integer, Dynamic = False, Default = \"40", Scope = Public
	#tag EndConstant

	#tag Constant, Name = rightMargin, Type = Double, Dynamic = False, Default = \"20", Scope = Public
	#tag EndConstant

	#tag Constant, Name = tickSize, Type = Double, Dynamic = False, Default = \"5", Scope = Public
	#tag EndConstant

	#tag Constant, Name = topMargin, Type = Double, Dynamic = False, Default = \"10", Scope = Public
	#tag EndConstant


	#tag Enum, Name = PlotType, Type = Integer, Flags = &h0
		Bar
		  Line
		Scatter
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabStop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AutoDeactivate"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Backdrop"
			Visible=true
			Group="Appearance"
			Type="Picture"
			EditorType="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HelpTag"
			Visible=true
			Group="Appearance"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="UseFocusRing"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AcceptFocus"
			Visible=true
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AcceptTabs"
			Visible=true
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DoubleBuffer"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Transparent"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="BarColor"
			Visible=true
			Group="Behavior"
			InitialValue="color.blue"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShowAxis"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ShowTicks"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AxisColor"
			Visible=true
			Group="Behavior"
			InitialValue="color.blue"
			Type="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabPanelIndex"
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="EraseBackground"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InitialParent"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PType"
			Group="Behavior"
			InitialValue="PlotType.Line"
			Type="PlotType"
			EditorType="Enum"
			#tag EnumValues
				"0 - Bar"
				"1 - Line"
				"2 - Scatter"
			#tag EndEnumValues
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
