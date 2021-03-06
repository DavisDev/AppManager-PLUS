function getvpks(_path, noscan)
	local tmp = files.list(_path)	
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			if tmp[i].ext then
				local extension = tmp[i].ext:lower()
				local pathtociso = files.nofile(tmp[i].path:lower())

				if extension == "vpk" or extension == "mp4" or extension == "cso" or extension == "iso" then
					local _type = files.type(tmp[i].path)

					if _type == 5 then											--Its really vpk
						if extension != "vpk" then
							local new_name =  tmp[i].name:gsub(extension,"vpk")
							local fullpath = files.nofile(tmp[i].path)
							files.rename(tmp[i].path,new_name)
							tmp[i].path = fullpath+new_name
							tmp[i].name = new_name
							tmp[i].ext = "vpk"
						end
						table.insert(list_vpks.data, tmp[i])

					elseif _type == 7 then										--Its really rar
						if extension != "rar" then
							local new_name =  tmp[i].name:gsub(extension,"rar")
							local fullpath = files.nofile(tmp[i].path)
							files.rename(tmp[i].path,new_name)
							tmp[i].path = fullpath+new_name
							tmp[i].name = new_name
							tmp[i].ext = "rar"
						end
						--table.insert(list_vpks.data, tmp[i])

					elseif _type == 5 then										--Its really zip
						if extension != "zip" then
							local new_name =  tmp[i].name:gsub(extension,"zip")
							local fullpath = files.nofile(tmp[i].path)
							files.rename(tmp[i].path,new_name)
							tmp[i].path = fullpath+new_name
							tmp[i].name = new_name
							tmp[i].ext = "zip"
						end
						--table.insert(list_vpks.data, tmp[i])

					elseif _type == 2 or _type == 3 then						--Its really iso/cso
						if extension == "iso" or extension == "cso" then
							if ( (pathtociso:sub(1,16) != "ux0:/pspemu/iso/") and (pathtociso:sub(1,16) != "ur0:/pspemu/iso/") ) then
								table.insert(list_vpks.data, tmp[i])
							end
						else
							if (pathtociso:sub(1,16) != "ux0:/pspemu/iso/") and (pathtociso:sub(1,16) != "ur0:/pspemu/iso/") then
								_ext="iso"
								if _type == 3 then _ext="cso" end

								local new_name =  tmp[i].name:gsub(extension, _ext)
								local fullpath = files.nofile(tmp[i].path)
								files.rename(tmp[i].path,new_name)
								tmp[i].path = fullpath+new_name
								tmp[i].name = new_name
								tmp[i].ext = _ext
								table.insert(list_vpks.data, tmp[i])
							end
						end
					end
				end--extension

			else
				if noscan != 0 then
					if tmp[i].directory then getvpks(tmp[i].path) end
				end

			end--tmp[i].ext

		end--for
	end
end

function scan(full)
	list_vpks = nil
	list_vpks = {data = {}, len = 0}

	if full == 1 then
		getvpks("ux0:",1)
		getvpks("ur0:",1)
	else
		getvpks("ux0:video/")
		getvpks("ux0:data/")
		getvpks("ux0:vpk/")
		getvpks("ur0:video/")
		getvpks("ur0:data/")
		getvpks("ur0:vpk/")
		getvpks("ux0:",0)
		getvpks("ur0:",0)
	end

	list_vpks.len = #list_vpks.data
	
	if list_vpks.len<=0 then
		local titlew = screen.textwidth(strings.wait) + 30
		draw.fillrect(450-(titlew/2),272-20,titlew,70,theme.style.BARCOLOR)
		draw.rect(450-(titlew/2),272-20,titlew,70,color.white)
		screen.print(450,272-20+13,strings.wait,1,color.white,color.black,__ACENTER)
		screen.flip()
		getvpks("ux0:",1)
		getvpks("ur0:",1)
		list_vpks.len = #list_vpks.data
	end

	if list_vpks.len<=0 then os.message(strings.nofinds) return end

	table.sort(list_vpks.data,function(a,b) return string.lower(a.name)<string.lower(b.name) end)

	local srcn = newScroll(list_vpks.data,15)
	buttons.interval(10,10)
	while true do
		buttons.read()

		if theme.data["list"] then theme.data["list"]:blit(0,0) end

		screen.print(480,15,strings.vpktittle,1,theme.style.TITLECOLOR,color.blue,__ACENTER)
		screen.print(950,15,strings.count + list_vpks.len,1,color.red,theme.style.BKGCOLOR,__ARIGHT)

		if list_vpks.len > 0 then
			if buttons.up or buttons.analogly < -60 then srcn:up() end
			if buttons.down or buttons.analogly > 60 then srcn:down() end

			if buttons[accept] then
				if list_vpks.data[srcn.sel].ext:lower() == "vpk" then

					buttons.homepopup(0)
						show_msg_vpk(list_vpks.data[srcn.sel])
					buttons.homepopup(1)

				elseif list_vpks.data[srcn.sel].ext:lower() == "iso" or list_vpks.data[srcn.sel].ext:lower() == "cso" then

					if list_vpks.data[srcn.sel].path:sub(1,3) == "ux0" then
						reboot=false
						files.move(list_vpks.data[srcn.sel].path,"ux0:pspemu/ISO")
						reboot=true

						if not files.exists(list_vpks.data[srcn.sel].path) then
							table.remove(list_vpks.data, srcn.sel)
							srcn:set(list_vpks.data,15)
							os.message(strings.moveiso2ux0)
						end

					elseif list_vpks.data[srcn.sel].path:sub(1,3) == "ur0" then
						reboot=false
						files.move(list_vpks.data[srcn.sel].path,"ur0:pspemu/ISO")
						reboot=true
	
						if not files.exists(list_vpks.data[srcn.sel].path) then
							table.remove(list_vpks.data, srcn.sel)
							srcn:set(list_vpks.data,15)
							os.message(strings.moveiso2ur0)
						end
					end
				end

				buttons.read()
				if vpkdel then
					table.remove(list_vpks.data, srcn.sel)
					srcn:set(list_vpks.data,15)
					vpkdel=false
				end
			end

			if buttons.square then
				if os.message(strings.delete.." "..list_vpks.data[srcn.sel].name.." ?",1) == 1 then
					reboot=false
						files.delete(list_vpks.data[srcn.sel].path)
						if not files.exists(list_vpks.data[srcn.sel].path) then
							table.remove(list_vpks.data, srcn.sel)
							srcn:set(list_vpks.data,15)
						end
					reboot=true
				end
			end

			local y = 70
			for i=srcn.ini,srcn.lim do
				if i == srcn.sel then draw.fillrect(10,y-2,930,23,theme.style.SELCOLOR) end

				screen.print(20,y,'#'+string.format("%02d",i)+' ) '+list_vpks.data[i].path,1.0,color.white,theme.style.BKGCOLOR,__ALEFT)

				y+=26
			end

		else
			screen.print(10,30,strings.empty,1.0,color.white,color.blue)
		end

		if theme.data["buttons2"] then
			theme.data["buttons2"]:blitsprite(10,515,0)--select
		end
		screen.print(45,520,strings.reloadfull,1.0,color.white,theme.style.BKGCOLOR,__ALEFT)

		if buttons.select then
			local titlew = screen.textwidth(strings.wait) + 30
			draw.fillrect(450-(titlew/2),272-20,titlew,70,theme.style.BARCOLOR)
			draw.rect(450-(titlew/2),272-20,titlew,70,color.white)
			screen.print(450,272-20+13,strings.wait,1,color.white,color.black,__ACENTER)
			screen.flip()
			scan(1)
		end

		if buttons.start then											--USB
			usbMassStorage()
		end

		if buttons.circle then selmenu = 2 break end
		if (buttons.held.l and buttons.held.r and buttons.up) and reboot then os.restart() end

		screen.flip()

	end
end
