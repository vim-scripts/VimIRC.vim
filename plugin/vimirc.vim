" An IRC client plugin for Vim
" Maintainer: Madoka Machitani <madokam@zag.att.ne.jp>
" Created: Tue, 24 Feb 2004
" Last Change: Fri, 28 May 2004 16:13:17 +0900 (JST)
" License: Distributed under the same terms as Vim itself
"
" Credits:
"   ircII		the basics of IRC
"   X-Chat		ideas for DCC implementation specifically
"   ERC			ideas for netsplit handling, auto-away feature etc.
"   KoRoN		creator of a BBS viewer for Vim, Chalice (very popular
"			among Japanese vim community)
"   Ilya Sher		an idea for mini-buffers for cmdline editing
"   morbuz		pointing out the error "E28: No such highlight group"
"			with s:Hilite* functions
"   alexander		pointing out the excessive CPU-time consumption,
"			feature of multiple server-connection on startup, etc
"
" Features:
"   * real-time message receiving with user interaction (many of the normal
"     mode commands available)
"   * multiple server/channel connectivity
"   * DCC SEND/CHAT functionalities
"   * logging
"   * command aliasing
"   * auto-join channels on logon
"   * auto-reconnect/rejoin after disconnect
"   * auto-away
"   * netsplit detection
"
"   A Drawback:
"     VimIRC achieves real-time message reception by implementing its own main
"     loop.  Therefore, while you are out of it, VimIRC has no way to get new
"     messages.
"
"     So my recommendation is, use a shortcut which creates a VimIRC-dedicated
"     instance of Vim, where you do not initiate normal editing sessions.
"
" Requirements:
"   * Vim 6.2 or later with perl interface enabled
"   * Perl (preferably 5.8 or later if you want multibyte feature)
"
" Options:
"
"   Basic settings:
"     let g:vimirc_nick		="nickname"
"     let g:vimirc_user		="username"
"     let g:vimirc_realname	="full name"
"     let g:vimirc_server	="irc.foobar.com:6667"
"				  Your favorite IRC server
"				  (default: irc.freenode.net)
"     let g:vimirc_umode	="user modes" set upon logon (e.g.: "+i")
"
"   Misc.:
"
"     let g:vimirc_autojoin	="#chan1,#chan2"
"				="#chan1|#chan2@irc.foo.com,#chan3@irc.bar.com"
"
"				  List of channels to join upon logon
"
"     let g:vimirc_nickpass	="pass@irc.foo.com"
"				="nick:pass@irc.foo.com"
"				="nick1:pass1|nick2:pass2@irc.foo.com"
"
"				  List of passwords to identify yourself to
"				  NickServ.
"
"				  The first form can be used if you are using
"				  the same pass for different nicks, or you
"				  have only one nick registered.
"
"				  Use commas to separate settings for each
"				  server.  (Only irc.freenode.net is
"				  supported currently)
"
"     let g:vimirc_log		=NUMBER
"				  Set this to non-zero to enable logging
"				  feature.  (default: zero)
"				  Logs will be taken for each channel and
"				  server independently.
"
"				  Since server buffers are usually not
"				  interesting (is it?), they'll be logged only
"				  if NUMBER is greater than 1.
"     let g:vimirc_logdir	="where log files are saved"
"				  (default: ~/.vimirc)
"				  The specified directory will be created
"				  automatically.
"
"     let g:vimirc_partmsg	="message sent with QUIT/PART"
"
"     let g:vimirc_winmode	="single" is the only valid value.
"				  (default: multi-windows mode)
"
"   Auto-away feature:
"     let g:vimirc_autoaway	=NUMBER
"				  Set to non-zero to enable the feature.
"				  (default: zero)
"     let g:vimirc_autoawaytime	=NUMBER
"				  Threshold time in seconds after which you
"				  will be marked as `away'
"				  (default: 1800 (30 minutes))
"
"   DCC-related:
"     let g:vimirc_dccdir	="where files are downloaded"
"				  (default: ~/.vimirc/dcc)
"     let g:vimirc_dccport	=NUMBER
"				  Port-number to watch at when you set up
"				  a dcc server.  maybe necessary to set if you
"				  are behind firewall or something.
"
"   Runtime Options:
"     You can pass following options to the command :VimIRC, overriding the
"     vim variables above
"
"	-n nickname
"	-u username
"	-s server:port
"
"	Long option(s):
"
"	--realname="full name"
"
" Startup:
"   Type
"     :VimIRC<CR>
"
"   You will be prompted for several user information (nick etc.) if you have
"   not set options listed above.
"
" Usage:
"
"   Normal mode:  This is a pseudo normal mode.  Try your favorite Vim normal
"		  mode commands as usual.
"
"		  Typing "i" or "I" will let you in the `command mode'
"		  described below, just as you do in Vim to go insert mode.
"
"		  ":", "/" and "?" keys will prompt you to enter ex-commands
"		  or search strings as usual.
"
"		  Hit <Ctrl-C> to get out of control and freely move around
"		  or do ex commands.  Hit <Space> to re-enter the normal
"		  (online) mode again.
"
"		  Special cases:
"
"		  * In a channels list window (which should open up with /list
"		    command), you can type "o" to sort the list, "O" to
"		    reverse it (I took these mappings from Mutt the e-mail
"		    client).
"		    Hitting <CR> will prompt you whether to join the channel
"		    where the cursor is.
"
"		  * In a nicks window, you can hit <CR> to choose an action to
"		    take against the one whom the cursor is on.
"
"		  * <C-N> / <C-P> keys are available in all buffers, mapped to
"		    cycle forward/backward through channel/server buffers.
"		    Useful in single-window mode.
"
"   Command mode: This is just a normal buffer opened (at the bottom of the
"		  screen|below the current window).  Enter IRC commands here.
"		  Hitting <CR>, both in insert and normal mode, will send out
"		  the cursor line instantly either as a command or a message.
"
"		  Every IRC command starts with "/".  E.g.: /join #vim,#c
"
"		  Line without a leading slash will be sent as a message,
"		  normaly to the current channel.
"
"		  Type /help<CR> to see the list of available commands.  It's
"		  far from complete, though.
"
" Quit:
"   Type
"     /quit<CR>
"   in the IRC command line to disconnect with the current server.
"
"   Or to totally exit from the script, type
"     VimIRCQuit<CR>
"   on the VIM command line.
"
" TODOs:
"   * multibyte support (done? I don't think so)
"   * authentication (just add one line to send PASS)
"   * flood protection
"   * handling of channel-mode changes
"   * IPv6
"   * SSL
"   * nicks auto-identification (done for freenode)
"   * command-line completion (with tab key)
"   * handling of control characters (bold, underline etc.)
"   * scripting (?)
"   * help (both /help command and local help file)
"   * menus (I personally never use menus)
"   * etc. etc.
"
"   Done:
"   - command-line history (?)
"   - separate listing of channels with sorting facilities
"   - auto reconnect/rejoin
"   - ctcp, including dcc stuffs (well, mostly)
"   - timer (it hasn't been in todo list though)
"     - auto-away
"   - logging
"   - netsplit detection (?)
"   - command abbreviation (aliasing)
"
" Tips:
"   1.	If you see extreme slowness in vim startup time due to this plugin,
"	put "let loaded_vimirc=1" in your .vimrc to avoid loading this in
"	normal editing sessions.  Create a VimIRC-dedicated rc file (.vimircrc
"	or something) and put necessary settings into it.  Then set up an
"	alias (shortcut) which runs VimIRC, specifying the rc file you
"	created.  Like this:
"	  alias irc='gvim -i NONE -u ~/.vimircrc -c VimIRC'
"
"   2.	In single-window mode, you'll see buffer numbers appear next to the
"	server/channel names in the `info-bar'.  With them, you can easily
"	navigate servers/channels like this:
"	  :sb1

if exists('g:loaded_vimirc') || &compatible
  finish
endif
" Set this to zero when releasing, which I'll occasionally forget, for sure
let s:debug = 0
if !s:debug
  let g:loaded_vimirc = 1
endif

let s:save_cpoptions = &cpoptions
set cpoptions&

let s:version = '0.8.7'
let s:client  = 'VimIRC '.s:version

"
" Developing functions
"

"
" Start/Exit
"

command! -nargs=* VimIRC :call s:StartVimIRC(<q-args>)

function! s:ObtainUserInfo(args)
  " Maybe called more than once
  let retval = !strlen(a:args) && (exists('s:nick') && exists('s:user')
	\					      && exists('s:realname'))
  if !retval
    let s:nick = s:StrMatched(a:args, '-n\s*\(\S\+\)', '\1')
    if !strlen(s:nick)
      let s:nick = s:GetVimVar('g:vimirc_nick')
      if !strlen(s:nick)
	let s:nick = s:GetEnv('$IRCNICK')
	if !strlen(s:nick)
	  let s:nick = s:Input('Enter your nickname')
	endif
      endif
    endif

    let s:user = s:StrMatched(a:args, '-u\s*\(\S\+\)', '\1')
    if !strlen(s:user)
      let s:user = s:GetVimVar('g:vimirc_user')
      if !strlen(s:user)
	let s:user = s:GetEnv('$USER')
	if !strlen(s:user)
	  let s:user = s:Input('Enter your username')
	endif
      endif
    endif

    let s:realname = s:StrMatched(a:args,
	  \"--real\\%(name\\)\\==\\(['\"]\\)\\(.\\{-\\}\\)\\1", '\2')
    if !strlen(s:realname)
      let s:realname = s:GetVimVar('g:vimirc_realname')
      if !strlen(s:realname)
	let s:realname = s:GetEnv('$NAME')
	if !strlen(s:realname)
	  let s:realname = s:GetEnv('$IRCNAME')
	  if !strlen(s:realname)
	    let s:realname = s:Input('Enter your full name')
	  endif
	endif
      endif
    endif

    let s:umode = s:StrMatched(a:args, '-m\s*\(\S\+\)', '\1')
    if !strlen(s:umode)
      let s:umode = s:GetVimVar('g:vimirc_umode')
      if !strlen(s:umode)
	let s:umode = s:GetEnv('$IRCUMODE')
	if !strlen(s:umode)
	  let s:umode = 0
	endif
      endif
    endif
  endif

  let retval = (strlen(s:nick) && strlen(s:user) && strlen(s:realname))
  if retval
    let s:server = s:StrMatched(a:args, '-s\s*\(\S\+\)', '\1')
    if !strlen(s:server)
      let s:server = s:GetVimVar('g:vimirc_server')
      if !strlen(s:server)
	let s:server = 'irc.freenode.net:6667'
      endif
    endif
  else
    unlet s:nick s:user s:realname s:umode
  endif

  return retval
endfunction

function! s:InitVars()
  if exists('s:sid') " already inited
    return
  endif

  map <SID>xx <SID>xx
  let s:sid = substitute(maparg('<SID>xx'), 'xx$', '', '')
  unmap <SID>xx

  let s:bufname_prefix	= '_VimIRC_'
  let s:bufname_info	= s:bufname_prefix.'INFO_'
  let s:bufname_server	= s:bufname_prefix.'SERVER_'
  let s:bufname_list	= s:bufname_prefix.'LIST_'
  let s:bufname_channel = s:bufname_prefix.'CHANNEL_'
  let s:bufname_nicks	= s:bufname_prefix.'NICKS_'
  let s:bufname_command = s:bufname_prefix.'COMMAND_'
  let s:bufname_chat	= s:bufname_prefix.'CHAT_'

  let s:autocmd_disable = 0

  " When timer was last triggered
  let s:lasttime = localtime()
  " When user did some action most recently
  let s:lastactive = s:lasttime

  " User options below

  " Favorite farewell message
  call s:SetVarIntern('vimirc_partmsg', (s:debug ? 'Testing ' : '').
	\s:client.' (IRC client for Vim)')
  " Prepend a leading colon
  let s:partmsg = substitute(s:partmsg, '^[^:]', ':&', '')

  " Preferred language.  Encoding name which Perl's Encode module can accept
  call s:SetVarIntern('vimirc_preflang')

  " On/off logging feature
  call s:SetVarIntern('vimirc_log', 0)
  " Log directory
  call s:SetVarIntern('vimirc_logdir', expand('$HOME').'/.vimirc')
  let s:logdir = s:RegularizePath(s:logdir)

  call s:SetVarIntern('vimirc_rcfile', s:logdir.'/.vimircrc')

  " Directory where incoming dcc files should go
  call s:SetVarIntern('vimirc_dccdir', s:logdir.'/dcc')
  let s:dccdir = s:RegularizePath(s:dccdir)

  " Preferred port you want to listen to
  call s:SetVarIntern('vimirc_dccport')

  " Window-related
  " Window mode
  call s:SetVarIntern('vimirc_winmode')
  let s:singlewin = (s:winmode ==? 'single')

  call s:SetVarIntern('vimirc_infowidth')
  if s:infowidth <= 1
    let s:infowidth = 20
  endif

  " On/off auto-away feature
  call s:SetVarIntern('vimirc_autoaway', 0)
  " Threshold time to be set `away'.  MUST be in seconds
  call s:SetVarIntern('vimirc_autoawaytime')
  if (s:autoawaytime + 0) <= 0
    let s:autoawaytime = 60 * 30
  endif
endfunction

" Internalize user variables (for safety)
function! s:SetVarIntern(var, ...)
  let var = substitute(a:var, '^vimirc_', '', '')
  let s:{var} = s:GetVimVar('g:'.a:var)
  if !strlen(s:{var}) && a:0
    let s:{var} = a:1
  endif
  unlet! g:{a:var}
endfunction

function! s:SetGlobVars()
  let s:eadirection = &eadirection
  set eadirection=ver
  let s:equalalways = &equalalways
  set equalalways
  let s:lazyredraw = &lazyredraw
  "set nolazyredraw
  set lazyredraw
  let s:showbreak = &showbreak
  let &showbreak = '      '
  let s:statusline = &statusline
  let &statusline = '%{'.s:sid.'GetStatus()}%=%l/%L'
  let s:titlestring = &titlestring
  let s:winminheight = &winminheight
  set winminheight=1
  let s:winwidth = &winwidth
  set winwidth=12
endfunction

function! s:ResetGlobVars()
  let &eadirection = s:eadirection
  let &equalalways = s:equalalways
  let &lazyredraw = s:lazyredraw
  let &showbreak = s:showbreak
  let &statusline = s:statusline
  let &titlestring = s:titlestring
  let &winminheight = s:winminheight
  let &winwidth = s:winwidth
endfunction

function! s:StartVimIRC(...)
  if !has('perl')
    echoerr 'To use this, you have to build vim with perl interface. Exiting.'
    return
  endif

  if !exists('s:opened')
    let s:opened = 0
  endif
  if s:opened
    return
  endif

  call s:InitVars()
  if !s:ObtainUserInfo(a:0 ? a:1 : '')
    return
  endif

  call s:RC_Load()

  call s:SetGlobVars()
  call s:SetCmds()
  call s:SetAutocmds()
  call s:SetEncoding()

  call s:PerlIRC()
  call s:StartServer(s:server)

  let s:opened = 1
  call s:MainLoop()
endfunction

function! s:QuitVimIRC()
  call s:ResetCmds()
  call s:ResetAutocmds()
  call s:ResetGlobVars()

  call s:Send_GQUIT('QUIT', '')
  call s:ResetPerlVars()

  call s:CloseVimIRC()
  let s:opened = 0
endfunction

function! s:SetCmds()
  delcommand VimIRC
  command! VimIRCQuit :call s:QuitVimIRC()
endfunction

function! s:ResetCmds()
  delcommand VimIRCQuit
  command! -nargs=* VimIRC :call s:StartVimIRC()
endfunction

function! s:SetAutocmds()
  augroup VimIRC
    autocmd!
    " NOTE: Cannot use CursorHold to auto re-enter the loop: getchar() won't
    "	    get a char since key inputs will never be waited after that event.
    execute 'autocmd CursorHold' s:bufname_prefix.'* call s:OfflineMsg()'
    execute 'autocmd BufDelete' s:bufname_channel.'* call s:DelChanServ()'
    execute 'autocmd BufDelete' s:bufname_chat.'* call s:DelChanServ()'
    execute 'autocmd BufDelete' s:bufname_server.'* call s:DelChanServ()'
    execute 'autocmd BufHidden' s:bufname_channel.'* call s:PreCloseBuf_Channel()'
    execute 'autocmd BufHidden' s:bufname_chat.'* call s:PreCloseBuf_Chat()'
    execute 'autocmd BufHidden' s:bufname_server.'* call s:PreCloseBuf_Server()'
    execute 'autocmd BufWinEnter' s:bufname_channel.'* call s:PostOpenBuf_Channel()'
    execute 'autocmd BufWinEnter' s:bufname_chat.'* call s:PostOpenBuf_Chat()'
    execute 'autocmd BufWinEnter' s:bufname_server.'* call s:PostOpenBuf_Server()'
  augroup END
endfunction

function! s:ResetAutocmds()
  autocmd! VimIRC
endfunction

function! s:MainLoop()
  " NOTE: Take care of the recursion, it may cause some obscure troubles
  if !(s:GetVimVar('s:opened') && s:IsSockOpen())
    return
  endif

  " Clearing the vim command line
  echo ""
  while 1
    try
      let key = getchar(0)
      if ''.key != '0'
	call s:HandleKey(key)
	" Giving precedence to key-handling (?)
	continue
      endif
      if s:DoTimer(!s:RecvData())
	break
      endif
    catch /^IMGONNA/
      " Get out of the loop
      " NOTE: You cannot see new messages posted while posting
      break
    catch /^Vim:Interrupt$/
      match none
      if 1 && s:IsBufCommand()
	startinsert
      endif
      break
    endtry
  endwhile
endfunction

"
" .vimircrc manipulation
"

function! s:RC_Load()
  if filereadable(s:rcfile)
    execute 'source' s:rcfile
  endif
endfunction

function! s:RC_Open(force)
  return (a:force || filereadable(s:rcfile)) && s:OpenBuf('1split', s:rcfile)
endfunction

function! s:RC_Close()
  if s:SelectWindow(bufnr(s:rcfile)) >= 0
    if &modified
      silent! write!
    endif
    silent! close!
  endif
endfunction

function! s:RC_Varname(type, name)
  return 'vimirc_'.a:type.'_'.(a:name =~ '[^_[:alnum:]]'
	\			? '{"'.s:EscapeQuote(a:name).'"}' : a:name)
endfunction

function! s:RC_Section(section)
  if !search('^" '.a:section, 'w')
    if strlen(getline('$'))
      call append('$', '')
    endif
    call append('$', '" '.a:section)
    $
  endif
endfunction

function! s:RC_Set(type, name, value)
  call s:RC_Unset(a:type, a:name)
  let varname = s:RC_Varname(a:type, a:name)
  call append('.', 'let '.varname.' = "'.s:EscapeQuote(a:value).'"')
  let g:{varname} = a:value
endfunction

function! s:RC_Unset(type, name)
  let varname = s:RC_Varname(a:type, a:name)
  while search('\m'.s:EscapeMagic(varname).'\s*=', 'w')
    delete _
  endwhile
  unlet! g:{varname}
endfunction

"
" Buffer manipulation
"

" I'm using buffer numbers to access buffers: accessing by name will soon fail
" if user changes directory or something.
" NOTE: I removed the `server' argument from the functions below, just for
"	ease of typing (esp. on the perl's side).

function! s:GetBufNum(bufname)
  let bufnum = -1
  let varname = 's:bufnum_'.a:bufname
  if exists('{varname}')
    if bufloaded({varname})
      let bufnum = {varname}
    else
      unlet {varname}
    endif
  endif
  return bufnum
endfunction

function! s:GetBufNum_Info()
  return s:GetBufNum(s:GenBufName_Info())
endfunction

function! s:GetBufNum_Server(...)
  return s:GetBufNum(s:GenBufName_Server(a:0 ? a:1 : s:server))
endfunction

function! s:GetBufNum_List(...)
  return s:GetBufNum(s:GenBufName_List(a:0 ? a:1 : s:server))
endfunction

function! s:GetBufNum_Channel(channel, ...)
  return s:GetBufNum(s:GenBufName_Channel((a:0 ? a:1 : s:server), a:channel))
endfunction

function! s:GetBufNum_Nicks(channel, ...)
  return s:GetBufNum(s:GenBufName_Nicks((a:0 ? a:1 : s:server), a:channel))
endfunction

function! s:GetBufNum_Command(channel, ...)
  return s:GetBufNum(s:GenBufName_Command((a:0 ? a:1 : s:server), a:channel))
endfunction

function! s:GetBufNum_Chat(nick, server)
  return s:GetBufNum(s:GenBufName_Chat(a:server, a:nick))
endfunction

function! s:SetBufNum(bufname, bufnum)
  let s:bufnum_{a:bufname} = a:bufnum
endfunction

function! s:DeleteBufNum(bufnum)
  unlet! s:bufnum_{bufname(a:bufnum)}
endfunction

function! s:GenBufName_Info()
  return s:bufname_info
endfunction

function! s:GenBufName_Server(server)
  return s:bufname_server.a:server
endfunction

function! s:GenBufName_List(server)
  return s:bufname_list.a:server
endfunction

function! s:GenBufName_Channel(server, channel)
  return s:bufname_channel.s:SecureChannel(a:channel).'@'.a:server
endfunction

function! s:GenBufName_Nicks(server, channel)
  return s:bufname_nicks.s:SecureChannel(a:channel).'@'.a:server
endfunction

function! s:GenBufName_Command(server, channel)
  return s:bufname_command.s:SecureChannel(a:channel).'@'.a:server
endfunction

function! s:GenBufName_Chat(server, nick)
  return s:bufname_chat.s:EscapeFName(a:nick).'@'.a:server
endfunction

function! s:SecureChannel(channel)
  return s:EscapeFName(tolower(a:channel))
endfunction

function! s:IsBufIRC(...)
  return !match(bufname(a:0 && a:1 ? a:1 : '%'), s:bufname_prefix)
	\						&& exists('b:server')
endfunction

function! s:IsBufInfo(...)
  return !match(bufname(a:0 && a:1 ? a:1 : '%'), s:bufname_info)
endfunction

function! s:IsBufServer(...)
  return !match(bufname(a:0 && a:1 ? a:1 : '%'), s:bufname_server)
endfunction

function! s:IsBufList(...)
  return !match(bufname(a:0 && a:1 ? a:1 : '%'), s:bufname_list)
endfunction

function! s:IsBufChannel(...)
  return !match(bufname(a:0 && a:1 ? a:1 : '%'), s:bufname_channel)
endfunction

function! s:IsBufNicks()
  return !match(bufname(a:0 && a:1 ? a:1 : '%'), s:bufname_nicks)
endfunction

function! s:IsBufCommand(...)
  return !match(bufname(a:0 && a:1 ? a:1 : '%'), s:bufname_command)
endfunction

function! s:IsBufChat(...)
  return !match(bufname(a:0 && a:1 ? a:1 : '%'), s:bufname_chat)
endfunction

function! s:IsChannel(channel)
  return !match(a:channel, '[&#+!]')
endfunction

function! s:CanOpenChannel(...)
  let bufnum = a:0 && a:1 ? a:1 : bufnr('%')
  return (s:IsBufChannel(bufnum) || s:IsBufChat(bufnum)
	\ || s:IsBufServer(bufnum) || s:IsBufList(bufnum))
endfunction

function! s:VisitBuf_ChanServ()
  if !s:CanOpenChannel()
    let i = 1
    while 1
      let bufnum = winbufnr(i)
      if bufnum < 0 || s:CanOpenChannel(bufnum)
	if bufnum >= 0
	  call s:SelectWindow(bufnum)
	endif
	break
      endif
      let i = i + 1
    endwhile
  endif
  return s:CanOpenChannel()
endfunction

function! s:VisitBuf_Info()
  return (s:SelectWindow(s:GetBufNum_Info()) >= 0)
endfunction

function! s:VisitBuf_Server(...)
  return (s:SelectWindow(s:GetBufNum_Server(a:0 ? a:1 : s:server)) >= 0)
endfunction

function! s:VisitBuf_List(...)
  return (s:SelectWindow(s:GetBufNum_List(a:0 ? a:1 : s:server)) >= 0)
endfunction

function! s:VisitBuf_Channel(channel, ...)
  return (s:SelectWindow(s:GetBufNum_Channel(a:channel,
	\					(a:0 ? a:1 : s:server))) >= 0)
endfunction

function! s:VisitBuf_Nicks(channel, ...)
  return (s:SelectWindow(s:GetBufNum_Nicks(a:channel,
	\					(a:0 ? a:1 : s:server))) >= 0)
endfunction

function! s:VisitBuf_Chat(nick, ...)
  return (s:SelectWindow(s:GetBufNum_Chat(a:nick, (a:0 ? a:1 : s:server))) >= 0)
endfunction

"
" Opening buffers
"

function! s:OpenBuf(comd, ...)
  try
    " Avoid "not enough room" error
    let winminheight= &winminheight
    let winminwidth = &winminwidth
    set winminheight=0 winminwidth=0
    let v:errmsg = ''

    silent! execute a:comd.(a:0 && strlen(a:1) ? ' '.a:1 : '')
    setlocal noswapfile modifiable
  catch /^Vim:Interrupt$/
  finally
    let &winminheight = winminheight
    let &winminwidth  = winminwidth
  endtry
  return !strlen(v:errmsg)
endfunction

function! s:OpenBuf_Info()
  let bufnum = s:GetBufNum_Info()
  if !(bufnum >= 0 && s:SelectWindow(bufnum) >= 0)
    let comd = 'vertical topleft '.s:infowidth.'split'
    if bufnum >= 0
      call s:OpenBuf(comd, '+'.bufnum.'buffer')
    else
      let bufname = s:GenBufName_Info()
      call s:OpenBuf(comd, bufname)
      call s:InitBuf_Info(bufname)
    endif
  endif
  return 1
endfunction

function! s:OpenBuf_Server()
  let bufnum = s:GetBufNum_Server()
  let loaded = (bufnum >= 0)
  let singlewin = (s:singlewin || !s:opened)

  if !(loaded && s:SelectWindow(bufnum) >= 0)
    let comd = singlewin ? (loaded ? 'buffer' : 'edit').'!' : 'split'
    call s:VisitBuf_ChanServ()

    if loaded
      if singlewin
	call s:OpenBuf(comd, bufnum)
      else
	call s:OpenBuf(comd, '+'.bufnum.'buffer')
      endif
      if exists('b:dead')
	unlet b:dead
      endif
    else
      let bufname = s:GenBufName_Server(s:server)
      call s:OpenBuf(comd, bufname)
      call s:InitBuf_Server(bufname)
    endif
  endif
endfunction

function! s:OpenBuf_List()
  let bufnum = s:GetBufNum_List()
  let loaded = (bufnum >= 0)

  if !(loaded && s:SelectWindow(bufnum) >= 0)
    let comd = s:singlewin ? (loaded ? 'buffer' : 'edit') : 'vertical split'
    if s:singlewin
      call s:VisitBuf_ChanServ()
    else
      " Open it next to the server window
      call s:SelectWindow(s:GetBufNum_Server())
    endif

    if loaded
      if s:singlewin
	call s:OpenBuf(comd, bufnum)
      else
	call s:OpenBuf(comd, '+'.bufnum.'buffer')
      endif
    else
      let bufname = s:GenBufName_List(s:server)
      call s:OpenBuf(comd, bufname)
      call s:InitBuf_List(bufname)
    endif
  endif
endfunction

function! s:OpenBuf_Channel(channel)
  let bufnum = s:GetBufNum_Channel(a:channel)
  let loaded = (bufnum >= 0)

  if !(loaded && s:SelectWindow(bufnum) >= 0)
    let comd = s:singlewin ? (loaded ? 'buffer' : 'edit') : 'botright split'
    call s:VisitBuf_ChanServ()

    if loaded
      if s:singlewin
	call s:OpenBuf(comd, bufnum)
      else
	call s:OpenBuf(comd, '+'.bufnum.'buffer')
      endif
    else
      let bufname = s:GenBufName_Channel(s:server, a:channel)
      call s:OpenBuf(comd, bufname)
      call s:InitBuf_Channel(bufname, a:channel)
    endif
    " I don't remember why this is necessary
    if &l:winfixheight
      let &l:winfixheight = 0
    endif
  endif
endfunction

function! s:OpenBuf_Nicks(channel, ...)
  if !s:VisitBuf_Channel(a:channel, (a:0 ? a:1 : s:server))
    return 0
  endif

  let server = a:0 ? a:1 : s:server
  let bufnum = s:GetBufNum_Nicks(a:channel, server)
  let loaded = (bufnum >= 0)

  if !(loaded && s:SelectWindow(bufnum) >= 0)
    let comd = 'vertical belowright 12split'
    if loaded
      call s:OpenBuf(comd, '+'.bufnum.'buffer')
    else
      let bufname = s:GenBufName_Nicks(server, a:channel)
      call s:OpenBuf(comd, bufname)
      call s:InitBuf_Nicks(bufname, a:channel)
    endif
  endif
  return 1
endfunction

function! s:OpenBuf_Command()
  if !(s:GetVimVar('s:opened') && s:IsBufIRC())
    return
  endif

  " Set the current server appropriately, so the command/message will be sent
  " to the one user intended
  if exists('b:server')
    call s:SetCurServer(b:server)
  endif

  let channel = s:GetVimVar('b:channel')
  let chattin = strlen(channel) && !s:IsChannel(channel)
  let bufnum  = s:GetBufNum_Command(channel)

  " TODO: I think I should make it configurable where to open
  if 0
    let comd = 'botright 1split'
  else
    let comd = 'belowright 1split'
    if !(chattin || bufnum == bufnr('%'))
      call s:SelectWindow(strlen(channel) ? s:GetBufNum_Channel(channel)
	    \				  : s:GetBufNum_Server())
    endif
  endif

  " &equalalways will be restored when the command window is closed
  let &equalalways = 0
  if bufnum >= 0
    if s:SelectWindow(bufnum) < 0
      call s:OpenBuf(comd, '+'.bufnum.'buffer')
    endif
  else
    let bufname = s:GenBufName_Command(s:server, channel)
    call s:OpenBuf(comd, bufname)
    call s:InitBuf_Command(bufname, channel, chattin)
  endif

  if 1 && !&l:winfixheight
    setlocal winfixheight
  endif

  match none
  if strlen(getline('$'))
    call append('$', '')
  endif
  $
  startinsert
endfunction

function! s:EnterChanServ(split)
  let rx = '^\s*[-+]\=\[-\=\d\+\]\(\S\+\)\%(\s\+\(\S\+\)\)\=$'
  let line = getline('.')
  if line =~ rx
    let channel= s:StrMatched(line, rx, '\1')
    let server = s:StrMatched(line, rx, '\2')

    let save_server = s:server
    let s:server = strlen(server) ? server : channel

    if s:singlewin && a:split
      call s:VisitBuf_ChanServ()
      split
    endif

    if !strlen(server) " Must be a server
      call s:OpenBuf_Server()
    elseif s:IsChannel(channel)
      call s:OpenBuf_Channel(channel)
    else
      call s:OpenBuf_Chat(channel, server)
    endif
    let s:server = save_server
  endif
endfunction

function! s:OpenBuf_Chat(nick, server)
  let bufnum = s:GetBufNum_Chat(a:nick, a:server)
  let loaded = (bufnum >= 0)

  if !(loaded && s:SelectWindow(bufnum) >= 0)
    let comd = s:singlewin ? (loaded ? 'buffer' : 'edit') : 'botright split'
    call s:VisitBuf_ChanServ()

    if loaded
      if s:singlewin
	call s:OpenBuf(comd, bufnum)
      else
	call s:OpenBuf(comd, '+'.bufnum.'buffer')
      endif
    else
      let bufname = s:GenBufName_Chat(a:server, a:nick)
      call s:OpenBuf(comd, bufname)
      call s:InitBuf_Chat(bufname, a:nick, a:server)
    endif
  endif
endfunction

function! s:PostOpenBuf_Server()
  if s:autocmd_disable
    return
  endif

  let abuf = expand('<abuf>') + 0
  let server = getbufvar(abuf, 'server')
  if strlen(server) && s:singlewin
    call s:ResetChanServ(server, '')
  endif
endfunction

function! s:PostOpenBuf_Channel()
  if s:autocmd_disable
    return
  endif

  let abuf = expand('<abuf>') + 0
  let channel = getbufvar(abuf, 'channel')
  let server  = getbufvar(abuf, 'server')
  let orgbuf  = bufnr('%')
  if strlen(channel) && strlen(server)
    call s:OpenBuf_Nicks(channel, server)
    call s:SelectWindow(orgbuf)
    if s:singlewin
      call s:ResetChanServ(server, channel)
    endif
  endif
endfunction

function! s:PostOpenBuf_Chat()
  if s:autocmd_disable
    return
  endif

  let abuf  = expand('<abuf>') + 0
  let nick  = getbufvar(abuf, 'channel')
  let server= getbufvar(abuf, 'server')
  if strlen(nick) && strlen(server)
    if s:singlewin
      call s:ResetChanServ(server, nick)
    endif
  endif
endfunction

function! s:PrePeekBuf()
  let s:autocmd_disable = 1
  let &equalalways = 0
  call s:VisitBuf_ChanServ()
  call s:OpenBuf('vertical 1split')
endfunction

function! s:PostPeekBuf()
  silent! close!
  let s:autocmd_disable = 0
  let &equalalways = 1
endfunction

"
" Buffer initilization
"

function! s:DoSettings()
  setlocal bufhidden=hide
  setlocal buftype=nofile
  setlocal nolist
  setlocal nonumber
  setlocal noswapfile
  setlocal wrap
  nnoremap <buffer> <silent> <Space>  :call <SID>MainLoop()<CR>
  nnoremap <buffer> <silent> i	      :call <SID>OpenBuf_Command()<CR>
  nnoremap <buffer> <silent> I	      :call <SID>OpenBuf_Command()<CR>
  nnoremap <buffer> <silent> <C-N>    :call <SID>WalkThruChanServ(1)<CR>
  nnoremap <buffer> <silent> <C-P>    :call <SID>WalkThruChanServ(0)<CR>
endfunction

function! s:DoHilite()
  " NOTE: I'm really bad at syntax highlighting.  It's horrible
  " NOTE: Do not overdo.  It'll slow things down
  syntax match VimIRCUserHead display "^\S\+\%( \S\+:\)\=" contains=@VimIRCUserName
  syntax match VimIRCTime display "^\d\d:\d\d" containedin=VimIRCUserHead contained
  syntax match VimIRCBullet display "[*!]" containedin=VimIRCUserHead contained
  " User names
  syntax cluster VimIRCUserName contains=VimIRCUserPrivMSG,VimIRCUserNotice,VimIRCUserAction,VimIRCUserQuery
  syntax match VimIRCUserPrivMSG  display "<\S\+>" contained
  syntax match VimIRCUserNotice	  display "\[\S\+\]" contained
  syntax match VimIRCUserAction	  display "\*\S\+\*" contained
  syntax match VimIRCUserQuery	  display "?\S\+?" containedin=VimIRCUserHead contained

  syntax match VimIRCUnderline	  display ".\{-\}" contains=VimIRCIgnore
  syntax match VimIRCBold	  display ".\{-\}" contains=VimIRCIgnore
  syntax match VimIRCIgnore	  display "[]" contained

  highlight link VimIRCTime	    String
  highlight link VimIRCUserHead	    PreProc
  highlight link VimIRCBullet	    WarningMsg
  highlight link VimIRCUserPrivMSG  Identifier
  highlight link VimIRCUserNotice   Statement
  highlight link VimIRCUserAction   WarningMsg
  highlight link VimIRCUserQuery    Question
  highlight link VimIRCUnderline    Underlined
  highlight VimIRCBold	  gui=bold term=bold
  if 1
    " FIXME: This doesn't work
    highlight link VimIRCIgnore	    Ignore
  else
    highlight! link SpecialKey Ignore
  endif
endfunction

function! s:DoHilite_Info()
  syntax match InfoHasNew "^\s*+.*$" contains=InfoIndic,InfoBufNum
  syntax match InfoDead "^\s*-.*$" contains=InfoIndic,InfoBufNum
  syntax match InfoIndic "^\s*[+-]" contained
  syntax match InfoBufNum "\[-\=\d\+\]"

  highlight link InfoHasNew DiffChange
  highlight link InfoDead   Comment
  highlight link InfoIndic  Ignore
  highlight link InfoBufNum Comment
endfunction

function! s:DoHilite_Server()
  call s:DoHilite_Channel()
  syntax match VimIRCWallop display "!\S\+!" contained containedin=VimIRCUserHead

  highlight link VimIRCWallop	    WarningMsg
endfunction

function! s:DoHilite_List()
  syntax match VimIRCListChan "^[&#+!]\S\+\s\+\d\+" contains=VimIRCListMember
  syntax match VimIRCListMember "\<\d\+\>" contained

  highlight link VimIRCListChan	    Identifier
  highlight link VimIRCListMember   Number
endfunction

function! s:DoHilite_Channel()
  call s:DoHilite()
  syntax match VimIRCChanEnter display "->" contained containedin=VimIRCUserHead
  syntax match VimIRCChanExit display "<[-=]" contained containedin=VimIRCUserHead
  syntax match VimIRCChanPriv display "[@+]" contained containedin=@VimIRCUserName

  highlight link VimIRCChanEnter  DiffChange
  highlight link VimIRCChanExit	  DiffDelete
  highlight link VimIRCChanPriv	  Statement
endfunction

function! s:DoHilite_Nicks()
  syntax match VimIRCNamesChop "^@"
  syntax match VimIRCNamesVoice "^+"

  highlight link VimIRCNamesChop  Identifier
  "highlight link VimIRCNamesChop  Statement
  highlight link VimIRCNamesVoice Statement
endfunction

function! s:DoHilite_Chat()
  call s:DoHilite()
  syntax match VimIRCUserChat display "=\S\+=" containedin=VimIRCUserHead contained
  highlight link VimIRCUserChat Special
endfunction

function! s:InitBuf_Info(bufname)
  let b:server	= 'Connections'
  let b:title	= ' '.b:server
  call s:DoSettings()
  call s:DoHilite_Info()
  setlocal nowrap
  nnoremap <buffer> <silent> <CR>	:call <SID>EnterChanServ(0)<CR>
  nnoremap <buffer> <silent> <C-W><CR>	:call <SID>EnterChanServ(1)<CR>
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

function! s:InitBuf_Server(bufname)
  let b:server	= s:server
  let b:umode	= ''
  let b:title	= '  '.s:nick.' @ '.s:server
  call setline(1, s:GetTime(1).' *: Connecting with '.s:server.'...')
  call s:DoSettings()
  call s:DoHilite_Server()
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

function! s:InitBuf_List(bufname)
  let b:server	= s:server
  let b:title	= '  List of channels @ '.s:server
  call s:DoSettings()
  setlocal nowrap
  nnoremap <buffer> <silent> <CR> :call <SID>StartChannel()<CR>
  " I take Mutt's keys for sorting
  nnoremap <buffer> <silent> o	  :call <SID>SortSelect()<CR>
  nnoremap <buffer> <silent> O	  :call <SID>SortReverse()<CR>
  nnoremap <buffer> <silent> R	  :call <SID>UpdateList(0)<CR>
  call s:DoHilite_List()
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

function! s:InitBuf_Channel(bufname, channel)
  let b:server	= s:server
  let b:channel = a:channel
  let b:cmode	= ''
  let b:topic	= ''
  let b:title	= '  '.a:channel.' @ '.s:server
  call setline(1, s:GetTime(1).' *: Now talking in '.a:channel)
  call s:DoSettings()
  call s:DoHilite_Channel()
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

function! s:InitBuf_Nicks(bufname, channel)
  let b:server	= s:server
  let b:channel = a:channel
  let b:title	= a:channel
  call s:DoSettings()
  call s:DoHilite_Nicks()
  setlocal nowrap
  nnoremap <buffer> <silent> <CR> :call <SID>SelectNickAction(0)<CR>
  vnoremap <buffer> <silent> <CR> :call <SID>SelectNickAction(0)<CR>
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

function! s:InitBuf_Command(bufname, channel, chattin)
  let b:server	= s:server
  let b:channel = a:channel
  let b:query	= a:chattin ? a:channel : ''
  let b:title	= '  '.(a:chattin ? 'Querying' : 'Posting to').' '.
	\(strlen(a:channel) ? a:channel.' @ ' : '').s:server
  call s:DoSettings()
  nnoremap <buffer> <silent> <CR> :call <SID>SendLine(0)<CR>
  inoremap <buffer> <silent> <CR> <Esc>:call <SID>SendLine(0)<CR>
  nunmap <buffer> i
  nunmap <buffer> I
  " TODO: Forbid gq stuffs
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

function! s:InitBuf_Chat(bufname, nick, server)
  " NOTE: a:server is the name of the IRC server, not the dcc peer's
  let b:server	= a:server
  let b:channel = a:nick
  let b:title	= '  Chatting with '.a:nick
  call setline(1, s:GetTime(1).' *: Now chatting with '.a:nick)
  call s:DoSettings()
  call s:DoHilite_Chat()
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

"
" Closing buffers
"

function! s:PreCloseBuf_Server()
  if s:autocmd_disable
    return
  endif

  let abuf = expand('<abuf>') + 0
  let server = getbufvar(abuf, 'server')
  if strlen(server) " validity check
    let bufnum = s:GetBufNum_Command('', server)
    if bufnum >= 0
      call s:CloseWindow(bufnum)
    endif
  endif
endfunction

function! s:PreCloseBuf_Channel()
  if s:autocmd_disable
    return
  endif

  let abuf = expand('<abuf>') + 0
  let channel = getbufvar(abuf, 'channel')
  let server  = getbufvar(abuf, 'server')
  if strlen(channel) && strlen(server)
    call s:CloseBuf_Nicks(channel, server)
    let bufnum = s:GetBufNum_Command(channel, server)
    if bufnum >= 0
      call s:CloseWindow(bufnum)
    endif
  endif
endfunction

function! s:PreCloseBuf_Chat()
  if s:autocmd_disable
    return
  endif

  let abuf = expand('<abuf>') + 0
  let nick = getbufvar(abuf, 'channel')
  let server = getbufvar(abuf, 'server')
  if strlen(nick) && strlen(server)
    let bufnum = s:GetBufNum_Command(nick, server)
    if bufnum >= 0
      call s:CloseWindow(bufnum)
    endif
  endif
endfunction

function! s:CloseBuf_Server()
  " Close associated windows before closing the server window
  call s:CloseBuf_Command(1)
  call s:CloseBuf_List()

  let bufnum = s:GetBufNum_Server()
  if bufnum >= 0
    if s:log >= 2
      call s:LogBuffer(bufnum)
    endif
    "call s:CloseWindow(bufnum)
  endif
endfunction

function! s:CloseBuf_List()
  let bufnum = s:GetBufNum_List()
  if bufnum >= 0
    if s:singlewin
      call s:OpenBuf_Server()
    endif
    call s:CloseWindow(bufnum)
  endif
endfunction

function! s:CloseBuf_Channel(channel)
  let bufnum = s:GetBufNum_Channel(a:channel)
  if bufnum >= 0
    call s:LogBuffer(bufnum)
    if s:singlewin
      call s:OpenBuf_Server()
    endif
    call s:CloseWindow(bufnum)
  endif
endfunction

function! s:CloseBuf_Nicks(channel, server)
  let bufnum = s:GetBufNum_Nicks(a:channel, a:server)
  if bufnum >= 0
    call s:CloseWindow(bufnum)
  endif
endfunction

function! s:CloseBuf_Command(force)
  if !exists('s:channel')
    return
  endif

  let bufnum = s:GetBufNum_Command(s:channel)
  if bufnum >= 0 && s:SelectWindow(bufnum) >= 0
    call s:PreBufModify()
    if line('.') != line('$')
      move $
    endif
    call s:BufTrim()
    " Remove duplicates, if any
    if line('$') > 1
      let lastline = getline('$')
      call s:ExecuteSafe('keepjumps', 'normal! G$')
      while s:SearchLine(lastline) && line('.') != line('$')
	delete _
	.-1
      endwhile
    endif
    if strlen(getline('$'))
      call append('$', '')
      call s:ExecuteSafe('keepjumps', 'normal! G0')
    endif
    call s:PostBufModify()

    " Don't close if in query mode
    if a:force || !(strlen(b:query) || s:singlewin)
      call s:CloseWindow(bufnum)
    endif

    " Move the cursor back onto the channel where command mode was triggered.
    if strlen(s:channel)
      call s:VisitBuf_Cha{s:IsChannel(s:channel) ? 'nnel' : 't'}(s:channel)
    else
      call s:VisitBuf_Server()
    endif
    call s:HiliteLine('.')
  endif
endfunction

function! s:CloseBuf_Chat(nick, server)
  let save_server = s:server
  let s:server = a:server

  let bufnum = s:GetBufNum_Command(a:nick, a:server)
  if bufnum >= 0
    call s:CloseWindow(bufnum)
  endif

  let bufnum = s:GetBufNum_Chat(a:nick, a:server)
  if bufnum >= 0
    call s:LogBuffer(bufnum)
    if s:singlewin
      call s:OpenBuf_Server()
    endif
    call s:CloseWindow(bufnum)
  endif

  let s:server = save_server
endfunction

function! s:CloseVimIRC()
  wincmd b
  let v:errmsg = ''
  while 1
    if s:IsBufIRC()
      silent! close
      if strlen(v:errmsg)
	enew
	break
      endif
    else
      if winnr() == 1
	break
      endif
      wincmd W
    endif
  endwhile
endfunction

"
" Providing some user interaction
"

function! s:HandleKey(key)
  let char = nr2char(a:key)

  match none
  " TODO: Make some mappings user-configurable
  if char =~# '[:]'
    let comd = input(':')
    if strlen(comd)
      execute comd
      if comd =~# '^\%(ls\|mes\)'
	let char = s:PromptKey('Hit any key to continue')
	if char ==# ':'
	  return s:HandleKey(a:key)
	endif
      endif
    endif
  elseif char =~# '[ORo]' && s:IsBufList()
    if char ==# 'R'
      call s:UpdateList(1)
    else
      call s:Sort{char ==# 'o' ? 'Select' : 'Reverse'}()
    endif
  elseif char =~# '[AIOaio]'
    if s:IsBufCommand()
      if char ==? 'a'
	startinsert!
      else
	if char ==? 'o'
	  execute 'normal!' char
	elseif char ==# 'I'
	  normal! ^
	endif
	startinsert
      endif
    else
      call s:OpenBuf_Command()
    endif
    throw 'IMGONNAPOST'
  elseif char =~# '[/?]'
    call s:Cmd_SEARCH(char)
  elseif char == "\<CR>"
    if s:IsBufInfo()
      call s:EnterChanServ(0)
    elseif s:IsBufCommand()
      call s:SendLine(1)
    elseif s:IsBufList()
      call s:StartChannel()
    elseif s:IsBufNicks()
      call s:SelectNickAction(1)
    else
      execute 'normal!' char
    endif
  elseif char =~# '[p]'		" scroll backward
    execute 'normal!' nr2char(2)
  elseif char =~# '[ ]'		" scroll forward
    execute 'normal!' nr2char(6)
  elseif char == "\t"
    execute 'normal!' "1\<C-I>"
  elseif char == "\<C-N>" || char == "\<C-P>"
    call s:WalkThruChanServ(char == "\<C-N>")
  elseif char == "\<C-B>" || char == "\<C-F>"
	\ || char == "\<C-D>" || char == "\<C-U>"
	\ || char == "\<C-E>" || char == "\<C-Y>"
	\ || char == "\<C-L>"
	\ || char == "\<C-O>" || char == "\<C-^>"
	\ || char =~# '[-#$*+0;BEGHLMNW^behjklnw]'
    " One char commands
    silent! execute 'normal!' char
  elseif char =~# '[`FTfgmtz]'
    " Commands which take a second char
    execute 'normal!' char.nr2char(getchar())
  elseif (char + 0) || char == "\<C-W>"
    " Accept things like "15G", "<C-W>2k", etc.
    let comd = char
    while 1
      let key  = getchar()
      let comd = comd.nr2char(key)
      " Continue if it is a number
      if !(key >= 48 && key <= 57)
	break
      endif
    endwhile
    if comd == "\<C-W>\<CR>"
      if s:IsBufInfo()
	call s:EnterChanServ(1)
      endif
    else
      silent! execute 'normal!' comd
    endif
  endif
  " Discard excessive keytypes (Chalice)
  while getchar(0)|endwhile

  call s:SetLastActive()
  call s:Hilite{s:IsBufInfo() ? 'Line' : 'Column'}('.')
  echo ''|redraw
endfunction

function! s:SetLastActive()
  if !s:autoaway
    return
  endif

  let lastactive = s:lastactive
  let s:lastactive = localtime()
  " Clear the `away' status only if considered to be set
  if s:lastactive >= lastactive + s:autoawaytime
    " I just don't want to call this perl code every time you type something
    call s:Send_GAWAY('GAWAY', '')
  endif
endfunction

function! s:SendLine(inloop)
  " TODO: Do confirmation (preferably optionally)
  if !s:IsBufCommand()
    return
  endif

  call s:SetCurServer(b:server)
  call s:SetCurChannel(b:channel)

  let line = s:ExpandAlias(s:StrTrim(getline('.')))
  let comd = ''
  let args = ''

  let rx = '^/\(\S\+\)\%(\s\+\(.\+\)\)\=$'
  if line =~ rx
    let comd = toupper(s:StrMatched(line, rx, '\1'))
    let args = s:StrMatched(line, rx, '\2')

    " Further expand aliases
    if comd =~# '^\%(MSG\|QUERY\)$'
      if comd ==# 'QUERY'
	" Just entering/quitting query mode, not sending.
	if strlen(args)
	  call s:StartChat(args)
	else
	  call s:CloseBuf_Chat(b:query, s:server)
	endif
	return
      endif
      let comd = 'PRIVMSG'
    elseif comd =~# '^\%(ME\|DESCRIBE\)$'
      let comd = 'ACTION'
      if comd ==# 'ME'
	let args = (strlen(b:query) ? b:query : b:channel).' '.args
      endif
    elseif comd =~# '^\%(\%(RE\)\=CONNECT\)$'
      let comd = 'SERVER'
    elseif comd =~# '^\%(LEAVE\)$'
      let comd = 'PART'
    elseif comd =~# '^\%(BYE\|EXIT\|SIGNOFF\)$'
      let comd = 'QUIT'
    elseif comd =~# '^\%(NICKS\)$'
      let comd = 'NAMES'
    endif

    if strlen(args)
      " This is only for removing a leading colon which user (unnecessarily)
      " appended to the MESSAGE and adding back!  Silly and redundant
      "
      " Commands with the following form:
      "   COMMAND [MESSAGE]
      if comd =~# '^\%(G\=\%(AWAY\|QUIT\)\|WALLOPS\)$'
	let rx = '^:\=\(.\+\)$'
	if args =~ rx
	  let args = s:StrMatched(args, rx, ':\1')
	endif
      elseif comd =~# '^\%(USERHOST\|ISON\)$'
	" User might delimit targets with commas
	let args = s:StrCompress(substitute(args, ',', ' ', 'g'))
      else
	let rx = ''
	if comd =~# '^\%(PART\|TOPIC\|PRIVMSG\|NOTICE\|SQU\%(ERY\|IT\)\|KILL\|ACTION\)$'
	  " COMMAND TARGET [MESSAGE]
	  let rx = '^\(\S\+\)\s\+:\=\(.\+\)$'

	  " If user ommitted channels, supply the current one
	  if comd =~# '^\%(PART\|TOPIC\)$'
		\ && !s:IsChannel(matchstr(args, '^\S\+'))
		\ && strlen(s:channel)
	    let args = s:channel.(strlen(args) ? ' '.args : '')
	  endif
	elseif comd =~# '^\%(KICK\)$'
	  " COMMAND CHANNEL USER [MESSAGE]
	  let rx = '^\(\S\+\s\+\S\+\)\s\+:\=\(.\+\)$'
	endif
	if strlen(rx) && args =~ rx
	  let args = s:StrMatched(args, rx, '\1').s:StrMatched(args, rx, ' :\2')
	endif
      endif
    endif

    if exists('*s:Cmd_{comd}')
      call s:Cmd_{comd}(args)
    else
      if s:IsConnected(s:server)
	if exists('*s:Send_{comd}')
	  call s:Send_{comd}(comd, args)
	else
	  call s:DoSend(comd, args)
	endif
      else
	call s:PromptKey('Do /SERVER first to get connected', 'WarningMsg')
      endif
    endif
  elseif strlen(line)
    call s:PreSendMSG(line)
  endif

  call s:CloseBuf_Command(0) " might have been closed before we reach here
  unlet! s:channel

  if comd =~# '^\%(WHO\)$'
    " When receiving a bunch of lines, visit the server window beforehand:
    " avoid the flicker caused by cursor movement between server and
    " channel windows
    call s:VisitBuf_Server()
  endif

  " Don't scroll down when awaying, to keep the context
  if comd !~# 'AWAY' && (s:IsBufChannel() || s:IsBufChat() || s:IsBufServer())
    call s:ExecuteSafe('keepjumps', 'normal! Gzb')
    redraw
  endif

  call s:SetLastActive()
  if !a:inloop
    call s:MainLoop()
  endif
endfunction

" "/SET option value"
function! s:Cmd_SET(optval)
  let numopt = 'autoaway autoawaytime log dccport'
  let stropt = 'winmode'
  let rx = '^\(\S\+\)\%(\s\+\(.\+\)\)\=$'
  if a:optval =~ rx
    " Settable options
    let opt = tolower(s:StrMatched(a:optval, rx, '\1'))
    let val = s:StrMatched(a:optval, rx, '\2')
    if opt =~# "^\\%(".substitute(numopt, ' ', '\\|', 'g').'\)$'
      if strlen(val) && val !~ '\D'
	let s:{opt} = val
      endif
    elseif opt =~# "^\\%(".substitute(stropt, ' ', '\\|', 'g').'\)$'
      if strlen(val)
	if opt ==# 'winmode'
	  let s:singlewin = (val ==? 'single')
	endif
	let s:{opt} = val
      endif
    endif
    if exists('s:{opt}')
      call s:EchoHL('Current setting:', 'Title')
      echo opt ':' s:{opt}
      call s:PromptKey('Hit any key to continue')
      return
    endif
  endif

  call s:EchoHL('Current settings:', 'Title')
  while strlen(numopt)
    let opt = matchstr(numopt, '^\S\+')
    echo opt ':' s:{opt}
    let numopt = substitute(numopt, '^\S\+\s*', '', '')
  endwhile
  while strlen(stropt)
    let opt = matchstr(stropt, '^\S\+')
    echo opt ':' s:{opt}
    let stropt = substitute(stropt, '^\S\+\s*', '', '')
  endwhile
  call s:PromptKey('Hit any key to continue')
endfunction

function! s:Cmd_SEARCH(comd)
  let word = input(a:comd)
  if strlen(word)
    let @/ = word
  endif
  silent! execute 'normal!' (a:comd == '/' ? 'n' : 'N')
endfunction

function! s:StartServer(servers)
  let servers = a:servers
  while strlen(servers)
    let server = matchstr(servers, '^[^,]\+')
    call s:Cmd_SERVER(server)
    let servers = substitute(servers, '^[^,]\+,\=', '', '')
  endwhile
endfunction

function! s:StartChannel()
  let channel = matchstr(getline('.'), '^\S\+')
  if s:IsChannel(channel) && s:GetConf_YN('Join channel '.channel.'?')
    call s:SetCurServer(b:server)
    call s:Send_JOIN('JOIN', channel)
  endif
endfunction

function! s:StartChat(nick)
  " Open up a separate window as with DCC CHAT
  call s:CloseBuf_Command(0)
  call s:OpenBuf_Chat(a:nick, s:server)
  call s:OpenBuf_Command()
endfunction

function! s:SelectNickAction(inloop) range
  if !s:IsBufNicks()
    return
  endif

  let nicks = ''
  let i = a:firstline
  while i <= a:lastline
    let nick = substitute(getline(i), '^[@+]\+', '', '')
    if strlen(nick)
      let nicks = nicks.(strlen(nicks) ? ' ' : '').nick
    endif
    let i = i + 1
  endwhile

  let number= a:lastline - a:firstline + 1
  let comds = "&whois\n&query\n&control\n&dcc/ctcp"
  let choice= confirm('What do you do with '.nicks.'?', comds)
  if !choice
    return
  endif

  if number > 1 && !(choice % 2)
    echo 'Sorry, you cannot do it with mulitple persons at the same time'
    return
  endif

  if choice == 1
    while strlen(nicks)
      let nick = matchstr(nicks, '^\S\+')
      call s:DoSend('WHOIS', nick)
      let nicks = substitute(nicks, '^\S\+\s*', '', '')
    endwhile
  elseif choice == 2
    call s:StartChat(nicks)
    if a:inloop
      throw 'IMGONNAPOST'
    endif
    return
  elseif choice == 3
    let comds = "&1 Op\n&2 Deop\n&3 Voice\n&4 Devoice"
    let choice= confirm('Choose one of these:', comds)
    if !choice
      return
    endif

    let onoff = (choice % 2) ? '+' : '-'
    let mode  = choice >= 3 ? 'v' : 'o'
    call s:SetOpVoice(onoff, mode, nicks)
  elseif choice == 4
    let comds = "&send\n&chat\n&ping\n&time\n&version\nclient&info"
    let choice= confirm('Choose one of these:', comds)
    if !choice
      return
    endif

    let args = ''
    if choice > 2
      if choice == 3
	let args = 'ping'
      elseif choice == 4
	let args = 'time'
      elseif choice == 5
	let args = 'version'
      elseif choice == 6
	let args = 'clientinfo'
      endif
      if strlen(args)
	call s:Send_CTCP('CTCP', nicks.' '.args)
      endif
    else
      if choice == 1
	let fname = input('Enter filename: ')
	if filereadable(fname)
	  let args = 'send '.nicks.' '.fname
	endif
      else
	let args = 'chat '.nicks
      endif
      if strlen(args)
	call s:Send_DCC('DCC', args)
      endif
    endif
  endif

  call s:HiliteLine('.')
  if !a:inloop
    call s:MainLoop()
  endif
endfunction

function! s:UpdateList(inloop)
  if s:VisitBuf_List()
    call s:PreBufModify()
    call s:BufClear()
    call s:PostBufModify()
    call s:DoSend('LIST', '')
    if !a:inloop
      call s:MainLoop()
    endif
  endif
endfunction

"
" Controlling user privileges
"

function! s:SetOpVoice(onoff, mode, args)
  if !(strlen(b:channel) || s:IsChannel(a:args))
    return
  endif

  let nicks = a:args
  let channel = b:channel
  if s:IsChannel(a:args)
    let nicks = substitute(a:args, '^\S\+\s\+', '', '')
    let channel = matchstr(a:args, '^\S\+')
  endif
  if !strlen(nicks)
    return
  endif

  let nicks = s:StrCompress(substitute(nicks, ',', ' ', 'g'))
  let number= strlen(substitute(nicks, '\S\+', '', 'g')) + 1
  let modes = s:StrMultiply(a:mode, number)
  call s:DoSend('MODE', channel.' '.a:onoff.modes.' '.nicks)
endfunction

function! s:Cmd_OP(args)
  call s:SetOpVoice('+', 'o', a:args)
endfunction

function! s:Cmd_DEOP(args)
  call s:SetOpVoice('-', 'o', a:args)
endfunction

function! s:Cmd_VOICE(args)
  call s:SetOpVoice('+', 'v', a:args)
endfunction

function! s:Cmd_DEVOICE(args)
  call s:SetOpVoice('-', 'v', a:args)
endfunction

"
" Aliasing
"

function! s:ExpandAlias(line)
  let line = a:line
  let rx = '^/\(\S\+\)\%(\s\+\(.\+\)\)\=$'
  if a:line =~ rx
    let varname = s:RC_Varname('alias', toupper(s:StrMatched(a:line, rx, '\1')))
    if exists('g:{varname}')
      let args = s:StrMatched(a:line, rx, '\2')
      let line = g:{varname}.(strlen(args) ? ' '.args : '')
    endif
  endif
  return line
endfunction

function! s:Cmd_ALIAS(line)
  let rx = '^/\=\(\S\+\)\s\+/\=\(.\+\)$'
  if a:line =~ rx
    if s:RC_Open(1)
      let alias = toupper(s:StrMatched(a:line, rx, '\1'))
      let comd	= s:StrMatched(a:line, rx, '/\2')
      call s:RC_Section('Aliases')
      call s:RC_Set('alias', alias, comd)
    else
      call s:PromptKey('Failed in registering alias', 'Error')
    endif
    call s:RC_Close()
  else
    call s:PromptKey('Syntax: /ALIAS alias command (with arguments)',
	  \							'WarningMsg')
  endif
endfunction

function! s:Cmd_UNALIAS(alias)
  if s:RC_Open(0)
    call s:RC_Unset('alias', toupper(substitute(a:alias, '^/', '', '')))
  endif
  call s:RC_Close()
endfunction

"
" Help
"

function! s:Cmd_HELP(...)
  if a:0 && a:1 ==? 'dcc'
    return s:Cmd_DCCHELP()
  endif

  echohl Title
  echo " VimIRC Help\n\n"
  echo " Available commands:\n\n"
  echohl None
  echo "/server [host:port]"
  echo "\tTry to connect with a new server.  Or reconnect the current server"
  echo "\twhen no argument is given."
  echo "/quit [reason]"
  echo "\tDisconnect with the current server.  Synonym: exit."
  echo "\n"
  echo "/join channel(s) [key(s)]"
  echo "\tJoin specified channels.  Use commas to separate channels."
  echo "/part [channel(s)] [message]"
  echo "\tExit from the specified channels.  If channels are ommitted, exit"
  echo "\tfrom the current channel.  Synonym: leave."
  echo "\n"
  echo "/topic [channel] [topic]"
  echo "\tSet or show the current topic for channel."
  echo "\n"
  echo "/msg target message"
  echo "\tSend a message to a nick/channel."
  echo "message"
  echo "\tSend a message to the current channel, or the nick currently"
  echo "\tquerying with."
  echo "\n"
  echo "/query nick"
  echo "\tStart a query session with a user."
  echo "/query"
  echo "\tClose it."
  echo "\n"
  echo "/action target message"
  echo "\tSend a message to a nick/channel, playing some role."
  echo "/me message"
  echo "\tSend a message to the current channel/query target, playing some"
  echo "\trole."
  echo "\n"
  echo "/op [channel] nick(s)"
  echo "/voice [channel] nick(s)"
  echo "\tGive operator or voice privileges to the selected nick(s)."
  echo "\tUse spaces or commas to separate nicks."
  echo "/deop [channel] nick(s)"
  echo "/devoice [channel] nick(s)"
  echo "\tDeprive operator or voice privileges of the selected nick(s)."
  echo "\n"
  echo "/set [option] [value]"
  echo "\tSet or show internal option values.  List of settable options will"
  echo "\tbe displayed if option is ommited."
  echo "\n"
  echo "/alias /new-command /blah blah"
  echo "\tAdd a new command \"new-command\" which expands into \"blah blah\"."
  echo "/unalias /new-command"
  echo "\tRemove it."
  echo "\n"
  echo "/dcc help"
  echo "\tShow a help message for DCC commands."
  echo "\n"
  call s:PromptKey('Hit any key to continue')
endfunction

function! s:Cmd_DCCHELP()
  call s:EchoHL(" Available DCC commands:", 'Title')
  echo "\n"
  echo "/dcc send nick file"
  echo "\tOffer DCC SEND to nick"
  echo "/dcc chat nick"
  echo "\tOffer DCC CHAT to, or accept pending offer from, nick"
  echo "/dcc get [nick [file]]"
  echo "\tAccept pending SEND offer from nick"
  echo "/dcc close [type [nick]]"
  echo "\tClose SEND/CHAT/GET connection with nick"
  echo "/dcc list"
  echo "\tList all active/pending DCC connections"
  echo "\n"
  call s:PromptKey('Hit any key to continue')
endfunction

"
" Logging
"

function! s:LogBuffer(bufnum)
  if s:log && s:MakeDir(s:logdir) && bufloaded(a:bufnum)
	\ && (s:SelectWindow(a:bufnum) >= 0
	\     || s:OpenBuf('split', '+'.a:bufnum.'buffer'))
	\ && !(s:IsBufEmpty()
	\     || (exists('b:lastsave') && b:lastsave >= line('$')))
    let save_cpoptions = &cpoptions
    set cpoptions-=A

    let range = ((exists('b:lastsave') ? b:lastsave : 0) + 1).',$'
    let logfile = s:logdir.'/'.s:GenFName_Log()

    " If the file is loaded in another buffer, unload it
    if bufloaded(logfile) && bufnr(logfile) != bufnr('%')
      execute 'bunload!' logfile
    endif

    execute 'redir >>' logfile
    silent echo '(Logged at' s:GetTime(0).")\n"
    redir END
    silent! execute range.'write! >>' logfile

    let b:lastsave = line('$')
    let &cpoptions = save_cpoptions
  endif
endfunction

function! s:GenFName_Log()
  " I'm prepending your nick to avoid corrupted data in case you're running
  " several instances.  No locking.
  return s:EscapeFName(s:GetCurNick().'@'.b:server.(exists('b:channel')
	\					      ? '.'.b:channel
	\					      : ''))
endfunction

"
" Notifications
"

function! s:NotifyNewEntry(...)
  " If the bottom line is already visible, or just forced to do so,
  if a:0 && a:1 || (line('.') + (winheight(0) - (winline() - 1)) >= line('$'))
    " Scroll down
    call s:ExecuteSafe('keepjumps', 'normal! G')
    call s:HiliteLine('.')
  else
    " And if not, do not scroll.  User might want to stay there to read old
    " messages
    call s:Beep(1)
  endif
endfunction

function! s:OfflineMsg()
  echo s:IsSockOpen() ? s:IsBufCommand()
	\		? 'Hitting <CR> will send out the current line'
	\		: 'Hit <Space> to get online'
	\	      : 'Do /SERVER to get connected'
endfunction

function! s:UpdateTitleBar()
  let &titlestring = s:client." [".strftime('%H:%M').']: '.
	\(s:IsBufIRC()	? b:server.' '.(s:IsBufChannel()
	\				? b:channel.': '.b:topic : '')
	\		: fnamemodify(expand('%'), ':p'))
  " NOTE: Redrawing is necessary to update the title
  redraw
endfunction

function! s:GetStatus()
  return exists('b:title') ? b:title : bufname('%')
endfunction

function! s:SetUserMode(umode)
  let bufnum = s:GetBufNum_Server()
  if bufnum >= 0
    call setbufvar(bufnum, 'umode', a:umode)
    call setbufvar(bufnum, 'title', '  '.s:GetCurNick().
	  \' [+'.a:umode.'] @ '.s:server)
  endif
endfunction

function! s:SetChannelTopic(channel, topic)
  let bufnum = s:GetBufNum_Channel(a:channel)
  if bufnum >= 0
    call setbufvar(bufnum, 'topic', a:topic)
  endif
endfunction

function! s:SetChannelMode(channel, cmode)
  let bufnum = s:GetBufNum_Channel(a:channel)
  if bufnum >= 0
    call setbufvar(bufnum, 'cmode', a:cmode)
    call setbufvar(bufnum, 'title', '  '.a:channel." [".a:cmode.'] @ '.s:server)
  endif
endfunction

"
" Misc. utility functions
"

function! s:EscapeFName(str)
  return escape(a:str, '%#')
endfunction

function! s:EscapeMagic(str)
  return escape(a:str, '$*.\^~')
endfunction

function! s:EscapeQuote(str)
  return escape(a:str, '"\')
endfunction

function! s:EchoHL(mesg, hlname)
  try
    execute 'echohl' a:hlname
    echo a:mesg
  finally
    echohl None
  endtry
endfunction

function! s:SearchLine(line)
  return strlen(a:line) ? search('\m^'.s:EscapeMagic(a:line).'$', 'w') : 0
endfunction

function! s:GetEnv(var)
  let var = expand(a:var)
  if var ==# a:var
    let var = ''
  endif
  return var
endfunction

function! s:RegularizePath(path)
  let path = fnamemodify(a:path, ':p')
  let path = substitute(path, '\', '/', 'g')
  let path = substitute(path, '/\{2,\}', '/', 'g')
  let path = substitute(path, '/$', '', '')
  return path
endfunction

function! s:Resize(size, vert)
  execute (a:vert ? 'vertical ' : '').'resize' a:size
endfunction

function! s:GoToWindow(winnum)
  silent execute a:winnum.'wincmd w'
endfunction

function! s:SelectWindow(bufnum)
  let winnum = -1
  if a:bufnum
    let winnum = bufwinnr(a:bufnum)
    if winnum >= 0 && winnum != winnr()
      call s:GoToWindow(winnum)
    endif
  endif
  return winnum
endfunction

function! s:CloseWindow(bufnum)
  let &equalalways = 0
  let v:errmsg = ''
  while s:SelectWindow(a:bufnum) >= 0
    silent! close!
    if strlen(v:errmsg)
      break
    endif
  endwhile
  let &equalalways = 1
endfunction

function! s:Beep(times)
  if !a:times
    return
  endif

  try
    let line = line('.')
    let col  = col('.')
    let errorbells = &errorbells
    let visualbell = &visualbell
    set errorbells
    set novisualbell

    let i = 0
    normal! 0
    while i < a:times
      normal! h
      let i = i + 1
      if (a:times - i)  " do not sleep for the last time
	sleep 250 m
      endif
    endwhile
  finally
    let &errorbells = errorbells
    let &visualbell = visualbell
    call cursor(line, col)
  endtry
endfunction

function! s:ExecuteSafe(prefix, comd)
  execute (exists(':'.a:prefix) == 2 ? a:prefix : '') a:comd
endfunction

function! s:GetHiCursor()
  return has('gui') ? 'Cursor' : 'DiffText'
endfunction

function! s:HiliteColumn(bogus, ...)
  silent! execute 'match' (a:0 ? a:1 : s:GetHiCursor()) '/\%#\S*/'
endfunction

function! s:HiliteLine(lnum, ...)
  silent! execute 'match' (a:0 ? a:1 : s:GetHiCursor())
	\ '/^.*\%'.(a:lnum ? a:lnum : line(a:lnum)).'l.*$/'
endfunction

function! s:GetTime(short, ...)
  return strftime((a:short ? '%H:%M' : '%Y/%m/%d %H:%M:%S'),
	\				    (a:0 && a:1 ? a:1 : localtime()))
endfunction

function! s:UpdateStatusLine(...)
  if exists(':redrawstatus')
    "execute 'redrawstatus'.(a:0 && a:1 ? '!' : '')
    redrawstatus!
  endif
endfunction

function! s:PreBufModify(...)
  let s:save_undolevels = &undolevels
  set undolevels=-1
  call setbufvar((a:0 && a:1 ? a:1 : bufnr('%')), '&modifiable', 1)
endfunction

function! s:PostBufModify(...)
  if exists('s:save_undolevels')
    let &undolevels = s:save_undolevels
    unlet s:save_undolevels
  endif
  "call setbufvar((a:0 && a:1 ? a:1 : bufnr('%')), '&modifiable', 0)
endfunction

function! s:Input(mesg, ...)
  return s:StrCompress(input(a:mesg.': ', (a:0 ? a:1 : '')))
endfunction

function! s:InputS(mesg)
  return s:StrCompress(inputsecret(a:mesg.': '))
endfunction

function! s:PromptKey(mesg, ...)
  call s:EchoHL(a:mesg, a:0 ? a:1 : 'MoreMsg')
  let char = getchar()
  echo ''
  return nr2char(char)
endfunction

function! s:IsBufEmpty()
  return !(line('$') > 1 || strlen(getline(1)))
endfunction

function! s:GetVimVar(varname)
  return exists('{a:varname}') ? {a:varname} : ''
endfunction

function! s:GetConf_YN(mesg)
  call s:EchoHL(' '.a:mesg.' (y/[n]): ', 'Question')
  let char = getchar()
  echo ''
  return (nr2char(char) ==? 'y')
endfunction

function! s:StrMatched(str, pat, sub)
  " A wrapper function to substitute().  First extract an interesting part
  " upon which we perform matching, so that only necessary string (sub) will
  " be obtained.  An empty string will be returned on failure.
  " I took this clever trick from Chalice.
  return substitute(matchstr(a:str, a:pat), a:pat, a:sub, '')
endfunction

" Remove unnecessary spaces in a string
function! s:StrTrim(str)
  return substitute(a:str, '\%(^\s\+\|\s\+$\)', '', 'g')
endfunction

function! s:StrCompress(str)
  return substitute(s:StrTrim(a:str), '\s\{2,\}', ' ', 'g')
endfunction

function! s:StrMultiply(str, times)
  let str = a:str
  let i = 1
  while i < a:times
    let str = str.a:str
    let i = i + 1
  endwhile
  return str
endfunction

function! s:BufClear()
  silent %delete _
endfunction

function! s:BufTrim()
  while search('^\s*$', 'w') && line('$') > 1
    delete _
  endwhile
endfunction

"
" And the Perl part
"

if has('perl')
function! s:MakeDir(dir)
  if isdirectory(a:dir)
    return 1
  endif

  perl <<EOP
{
  VIM::DoCommand('return '.my_mkdir(scalar(VIM::Eval('a:dir'))));
}
EOP
endfunction

function! s:SetEncoding()
  " The idea is, we should load & use conversion-related codes only if
  " necessary
  let ircenc = ''
  " TODO: Deal with encodings other than Japanese
  if strlen(s:preflang)
    let ircenc = s:preflang
  elseif &encoding =~# '\%(cp932\|euc-jp\)'
    let ircenc = '7bit-jis'
  endif
  if !strlen(ircenc)
    return
  endif

  perl <<EOP
{
  use Encode;

  $ENC_VIM = VIM::Eval('&encoding');
  $ENC_IRC = VIM::Eval('l:ircenc');
}
EOP
endfunction

function! s:SortSelect()
  if !s:IsBufList()
    return
  endif

  let choice= confirm("Sort by what?", "&channel\n&member\n&topic")
  if !choice
    return
  endif

  if choice == 1
    let cmp = 'channel'
  elseif choice == 2
    let cmp = 'member'
  elseif choice == 3
    let cmp = 'topic'
  endif

  let orglin = getline('.')
  call s:PreBufModify()
  call s:SortList(cmp, (s:GetVimVar('b:sortdir') + 0))
  call s:PostBufModify()
  call s:SearchLine(orglin)
endfunction

function! s:SortReverse()
  if !s:IsBufList()
    return
  endif

  let orglin = line('.')
  call s:PreBufModify()
  perl $curbuf->Set(1, reverse($curbuf->Get(1 .. $curbuf->Count())))
  call s:PostBufModify()
  let b:sortdir = !(s:GetVimVar('b:sortdir'))
  execute (line('$') - orglin + 1)
endfunction

function! s:SortList(cmp, dir)
  perl <<EOP
{
  my $cmp = VIM::Eval('a:cmp');
  my $dir = VIM::Eval('a:dir');
  my @lns = $curbuf->Get(1 .. $curbuf->Count());

  if ($cmp eq 'channel')
    {
      @lns = map { $_->[0] }
	      sort {  if ($dir) { lc($b->[1]) cmp lc($a->[1]) }
		      else	{ lc($a->[1]) cmp lc($b->[1]) } }
		map { [ $_, /^(\S+).*$/ ] } @lns;
    }
  elsif ($cmp eq 'member')
    {
      @lns = map { $_->[0] }
	      sort {  if ($dir) { $b->[1] <=> $a->[1] }
		      else	{ $a->[1] <=> $b->[1] } }
		map { [ $_, /^\S+\s+(\d+).*$/ ] } @lns;
    }
  else
    {
      @lns = map { $_->[0] }
	      sort {  if ($dir) { $b->[1] cmp $a->[1] }
		      else	{ $a->[1] cmp $b->[1] } }
		map { [ $_, /^\S+\s+\d+\s*(.*)$/ ] } @lns;
    }
  $curbuf->Set(1, @lns);
}
EOP
endfunction

function! s:DoTimer(exit)
  let lasttime = localtime()
  if !(a:exit || lasttime > s:lasttime)
    return a:exit
  endif
  let s:lasttime = lasttime

  perl <<EOP
{
  my $save_cur = $Current_Server;

  do_timer(scalar(VIM::Eval('l:lasttime')));

  $Current_Server = $save_cur;
}
EOP

  call s:UpdateTitleBar()
  call s:UpdateStatusLine()

  return a:exit
endfunction

function! s:DelChanServ()
  let abuf = expand('<abuf>') + 0
  let server = getbufvar(abuf, 'server')
  let channel= getbufvar(abuf, 'channel')
  if !strlen(server)
    return
  endif

  perl <<EOP
{
  my $serv = VIM::Eval('l:server');
  my $chan = VIM::Eval('l:channel');

  if (my ($sref, $cref) = find_chanserv($serv, $chan))
    {
      if ($cref->{'bufnum'} >= 0)
	{
	  $cref->{'bufnum'} = -1;
	  $sref->{'info'} |= $INFO_UPDATE;
	}
    }
}
EOP
  call s:DeleteBufNum(abuf)
endfunction

function! s:ResetChanServ(server, channel)
  perl <<EOP
{
  my $serv = VIM::Eval('a:server');
  my $chan = VIM::Eval('a:channel');

  if (my ($sref, $cref) = find_chanserv($serv, $chan))
    {
      if ($cref->{'info'} & $INFO_HASNEW)
	{
	  $cref->{'info'} &= ~$INFO_HASNEW;
	  $sref->{'info'} |= $INFO_UPDATE;
	}
      if (is_channel($chan) && ($cref->{'info'} & $INFO_UPDATE))
	{
	  draw_nickwin($chan);
	  $cref->{'info'} &= ~$INFO_UPDATE;
	}
    }
}
EOP
endfunction

function! s:WalkThruChanServ(forward)
  if !s:VisitBuf_ChanServ()
    return
  endif

  perl <<EOP
{
  my @chanserv;
  my $orgbuf = VIM::Eval("bufnr('%')");

  foreach my $sref (@Servers)
    {
      if ($sref->{'bufnum'} >= 0)
	{
	  unshift(@chanserv, $sref->{'bufnum'});
	}

      if ((my $list = VIM::Eval("s:GetBufNum_List(\"$sref->{'server'}\")"))
									>= 0)
	{
	  unshift(@chanserv, $list);
	}

      foreach my $cref (@{$sref->{'chans'}})
	{
	  if ($cref->{'bufnum'} >= 0)
	    {
	      unshift(@chanserv, $cref->{'bufnum'});
	    }
	}
      foreach my $chat (@{$sref->{'chats'}})
	{
	  if ($chat->{'bufnum'} >= 0)
	    {
	      unshift(@chanserv, $chat->{'bufnum'});
	    }
	}
    }

  if ($#chanserv >= 0)
    {
      my $first = $chanserv[0];
      my $next	= $first;

      if ($#chanserv > 0)
	{
	  if (VIM::Eval('a:forward'))
	    {
	      @chanserv = reverse(@chanserv);
	      $first = $chanserv[0];
	    }

	  # Open the one next to $orgbuf
	  if ($first != $orgbuf)
	    {
	      while ($chanserv[0] != $orgbuf)
		{
		  push(@chanserv, shift(@chanserv));
		  # $orgbuf wasn't in the list: probably it was /LIST buffer or
		  # something
		  if ($chanserv[0] == $first)
		    {
		      last;
		    }
		}
	    }
	  $next = $chanserv[1];
	}

      if (vim_selectwin($next) < 0)
	{
	  VIM::DoCommand("silent buffer $next");
	}
    }
}
EOP
endfunction

function! s:SetCurServer(server)
  perl <<EOP
{
  if (my $sref = find_server(scalar(VIM::Eval('a:server'))))
    {
      $Current_Server = $sref;
      VIM::DoCommand("let s:server = \"$sref->{'server'}\"");
    }
}
EOP
endfunction

function! s:SetCurChannel(channel)
  let s:channel = a:channel
endfunction

function! s:GetCurNick()
  perl <<EOP
{
  my $nick;

  if (exists($Current_Server->{'nick'}))
    {
      $nick = $Current_Server->{'nick'};
    }
  else
    {
      $nick = vim_getvar('s:nick');
    }

  VIM::DoCommand('return "'.do_escape($nick).'"');
}
EOP
endfunction

function! s:Cmd_SERVER(server)
  let port = 0
  let server = strlen(a:server) ? a:server : s:GetVimVar('b:server')
  if !strlen(server)
    let server = s:Input('Enter server name')
    if !strlen(server)
      return
    endif
  endif

  let rx = '^\(\S\+\):\(\d\+\)$'
  if server =~ rx
    let port = s:StrMatched(server, rx, '\2') + 0
    let server = s:StrMatched(server, rx, '\1')
  else
    if 0
      let port = s:Input('Specify port number', 6667)
    else
      let port = s:GetVimVar('b:port') + 0
      if !port
	let port = 6667
      endif
    endif
  endif

  call s:CloseBuf_Command(1)
  if server !=# s:GetVimVar('s:server')
    let s:server = server
  endif

  "
  " Close the currently open server window (only if it is marked disconnected)
  let close = (s:IsBufIRC() && exists('b:dead') && b:server !=# server)
	\	? bufnr('%') : 0
  call s:OpenBuf_Server()
  if port != 6667
    let b:port = port
  endif

  $
  if close
    call s:CloseWindow(close)
  endif
  redraw

  perl <<EOP
{
  my $port  = VIM::Eval('l:port');
  my $server= VIM::Eval('l:server');

  my $nick  = VIM::Eval('s:GetCurNick()');

  if ($port <= 0)
    {
      $port = 6667;
    }

  $Current_Server = find_server($server);
  if ($Current_Server)
    {
      if (($Current_Server->{'conn'} & $CS_LOGIN)
	  && $Current_Server->{'port'} == $port)
	{
	  return;
	}

      close_server($Current_Server);
    }
  else
    {
      $Current_Server = add_server();
      $Current_Server->{'server'} = $server;
      $Current_Server->{'nick'}	  = $nick;
    }
  $Current_Server->{'port'} = $port;

  open_server($Current_Server);
}
EOP
endfunction

function! s:RecvData()
  let retval = 1

  perl <<EOP
{
  # MEMO: We're not using $WS currently, due to the blocking issue of syswrite
  my ($r, $w) = IO::Select->select($RS, $WS, undef, 0.2);
  my $sock;

  foreach $sock (@{$w})
    {
      dcc_check($sock, 1);
    }

  foreach $sock (@{$r})
    {
      unless (dcc_check($sock))
	{
	  unless (irc_recv($sock))
	    {
	      unless ($RS->count())
		{
		  VIM::DoCommand('let retval = 0');
		  last;
		}
	    }
	}
    }
}
EOP
  return retval
endfunction

function! s:IsConnected(server)
  let retval = 0

  perl <<EOP
{
  if (my $sref = find_server(scalar(VIM::Eval('a:server'))))
    {
      VIM::DoCommand('let retval = '.($sref->{'conn'} & $CS_LOGIN));
    }
}
EOP
  return retval
endfunction

function! s:IsSockOpen()
  perl <<EOP
{
  if (defined($RS))
    {
      VIM::DoCommand('return '.$RS->count());
    }
}
EOP
  return 0
endfunction

function! s:ResetPerlVars()
  perl <<EOP
{
  undef @Servers;
  undef %Clients;
  undef $Current_Server;
  undef $RS;
  undef $WS;
}
EOP
endfunction

function! s:Send_ACTION(comd, args)
  perl <<EOP
{
  if (my ($chan, $mesg) = (VIM::Eval('a:args') =~ /^(\S+) :(.+)$/))
    {
      unless (index($chan, '='))
	{
	  dcc_send_chat(substr($chan, 1), sprintf("\x01%s %s\x01",
						  scalar(VIM::Eval('a:comd')),
						  $mesg));
	}
      else
	{
	  my $nick = $Current_Server->{'nick'};

	  ctcp_send(1, $chan, "%s %s", scalar(VIM::Eval('a:comd')), $mesg);

	  if (is_channel($chan))
	    {
	      irc_add_line($chan, "*%s%s*: %s",
				    find_nickprefix($nick, $chan),
				    $nick, $mesg);
	    }
	  else
	    {
	      irc_chat_line($chan, "*%s*: %s", $nick, $mesg);
	    }
	}
    }
}
EOP
endfunction

function! s:Send_AWAY(comd, args)
  perl <<EOP
{
  my $comd = VIM::Eval('a:comd');

  if (my ($mesg) = (VIM::Eval('a:args') =~ /^:(.+)$/))
    {
      $Current_Server->{'away'} = $mesg;
      irc_send("%s :%s", $comd, $mesg);
    }
  elsif ($Current_Server->{'away'})
    {
      $Current_Server->{'away'} = undef;
      irc_send("%s", $comd);
    }
}
EOP
endfunction

function! s:Send_CTCP(comd, args)
  perl <<EOP
{
  if (my ($to, $comd, $args) = (VIM::Eval('a:args')
					    =~ /^(\S+)\s+(\S+)(?:\s+(.+))?$/))
    {
      $comd = uc($comd);

      if ($comd eq 'PING')
	{
	  $args = time();
	}

      unless (is_channel($to))	# sending ctcp to channel is rude except ACTION
	{
	  ctcp_send(1, $to, "%s%s", $comd, ($args ? " $args" : ""));
	}
    }
}
EOP
endfunction

function! s:Send_DCC(comd, args)
  " /DCC SEND nick file
  let type = ''
  let nick = ''
  let desc = ''
  let rx = '^\(\S\+\)\%(\s\+\(\S\+\)\%(\s\+\(.\+\)\)\=\)\=$'
  if a:args =~ rx
    let type = toupper(s:StrMatched(a:args, rx, '\1'))
    if type ==# 'HELP'
      return s:Cmd_DCCHELP()
    elseif type =~# '^\%(CLOSE\|SEND\|GET\|CHAT\)$'
      let nick = s:StrMatched(a:args, rx, '\2')
      let desc = s:StrMatched(a:args, rx, '\3')
      if type ==# 'SEND'
	let desc = s:RegularizePath(desc)
	if !filereadable(desc)
	  " TODO: Emit some error message
	  return
	endif
      endif
    endif
  endif
  if !strlen(type)
    let type = 'LIST'
  endif

  perl <<EOP
{
  my $type = VIM::Eval('l:type');
  my $nick = VIM::Eval('l:nick');
  my $desc = VIM::Eval('l:desc');

  my $dcc;

  if ($type eq 'CLOSE')
    {
      # /dcc close type [nick]
      $type = uc($nick);
      $nick = $desc;
      # Hmm, can't specify files

      if ($type)
	{
	  for (my $i = 1; $i < $#DCC_TYPES; $i++)
	    {
	      if ($type eq $DCC_TYPES[$i])
		{
		  $type = $i;
		  last;
		}
	    }
	  unless ($type & $DCC_TYPE)
	    {
	      $type = 0;
	    }
	}

      while ($dcc = find_dccclient($nick, $type, $desc))
	{
	  dcc_close($dcc);
	}
      return;
    }
  elsif ($type eq 'LIST')
    {
      dcc_show_list();
      return;
    }
  elsif ($type eq 'GET')
    {
      $dcc = find_dccclient($nick, $DCC_FILERECV, $desc);
      if ($dcc && ($dcc->{'flags'} & $DCC_ACTIVE))
	{
	  return;
	}
    }
  elsif ($type eq 'SEND')
    {
      $dcc = find_dccclient($nick, $DCC_FILESEND, $desc);
      if ($dcc)	  # already active or in queue
	{
	  return;
	}
      else
	{
	  $dcc = add_dccclient();
	  if ($dcc)
	    {
	      my ($fname) = ($desc =~ m#^(?:.*/)?(.+)$#);

	      $dcc->{'nick'}  = $nick;
	      $dcc->{'flags'} = $DCC_FILESEND;
	      $dcc->{'desc'}  = do_urlencode($fname);
	      $dcc->{'fname'} = $desc;
	      $dcc->{'fsize'} = (-s $desc);
	    }
	}
    }
  elsif ($type eq 'CHAT')
    {
      # Reuse already connected one, if found
      $dcc = find_dccclient($nick, $DCC_CHATSEND);
      if ($dcc) # it must already be in queue on the peer side
	{
	  return;
	}
      else
	{
	  $dcc = find_dccclient($nick, $DCC_CHATRECV);
	  unless ($dcc)
	    {
	      $dcc = add_dccclient();
	      if ($dcc)
		{
		  $dcc->{'nick'} = $nick;
		  $dcc->{'flags'}= $DCC_CHATSEND;
		  $dcc->{'desc'} = lc($type);
		}
	    }
	  if ($dcc)
	    {
	      vim_open_chat("=$nick", $dcc->{'iserver'}->{'server'});
	    }
	}
    }

  if ($dcc)
    {
      if ($dcc->{'flags'} & $DCC_QUEUED)
	{
	  dcc_they_accept($dcc);
	}
      elsif (!($dcc->{'flags'} & $DCC_ACTIVE))
	{
	  $dcc->{'flags'} |= $DCC_QUEUED;
	  dcc_open($dcc);
	}
    }
}
EOP
endfunction

function! s:Send_GAWAY(comd, args)
  call s:SendGlobally('AWAY', a:args)
endfunction

function! s:Send_GQUIT(comd, args)
  call s:SendGlobally('QUIT', a:args)
endfunction

function! s:Send_JOIN(comd, args)
  perl <<EOP
{
  my $chans = VIM::Eval('a:args');

  if ($chans eq '0')
    {
      irc_send("JOIN %s", $chans);
    }
  else
    {
      my (@chans, @keys);

      if (my ($chans, $keys) = ($chans =~ /^(\S+)(?:\s+(\S+))?$/))
	{
	  @chans = split(/,/, $chans);
	  @keys  = split(/,/, $keys);
	}

      foreach my $chan (@chans)
	{
	  my $key = shift(@keys);

	  if (is_channel($chan))
	    {
	      vim_open_channel($chan);

	      unless (find_channel($chan))  # not joined yet
		{
		  irc_send("JOIN %s%s", $chan, ($key ? " $key" : ""));
		  add_channel($chan, $key);
		}
	    }
	}
    }
}
EOP
  " I don't like to call CloseBuf_Command() in various parts, but I just want
  " to stay here (the last opened channel)
  let bufnum = bufnr('%')
  call s:CloseBuf_Command(1)
  call s:SelectWindow(bufnum)
endfunction

function! s:Send_LIST(comd, args)
  " MEMO: Some servers don't send "321 RPL_LISTSTART", so open a list buffer
  " before we send the command
  call s:OpenBuf_List()
  if !s:IsBufEmpty()
    return s:HiliteLine('.')
  endif
  call s:DoSend(a:comd, a:args)
endfunction

function! s:Send_NAMES(comd, args)
  let rx = '^\(\S\+\)\%(\s\+\(\S\+\)\)\=$'
  let chans = s:StrMatched(a:args, rx, '\1')
  let server= s:StrMatched(a:args, rx, '\2')
  if !strlen(chans) && exists('b:channel')
    let chans = b:channel
  else
    call s:VisitBuf_Server()
  endif

  perl <<EOP
{
  my $comd  = VIM::Eval('a:comd');
  my $chans = VIM::Eval('l:chans');
  my $server= VIM::Eval('l:server');

  if ($chans)
    {
      my $format = $chans ? " %s".($server ? " %s" : "") : "";

      foreach my $chan (split(/,/, $chans))
	{
	  if ($chan)
	    {
	      init_nicks($chan);
	    }
	  irc_send("%s$format", $comd, $chan, $server);
	}
    }
  else
    {
      irc_send("%s", $comd);
    }
}
EOP
endfunction

function! s:Send_NICK(comd, args)
  let nick = a:args
  if !strlen(a:args)
    let nick = s:Input('Enter a new nickname')
    if !strlen(nick)
      return
    endif
    echo ''
  endif
  call s:DoSend(a:comd, substitute(nick, '\s\+', '-', 'g'))
endfunction

function! s:Send_PART(comd, args)
  let args = strlen(a:args) ? a:args : (exists('b:channel')
	\				? b:channel.' '.s:partmsg : '')
  if !strlen(args)
    return
  endif

  perl <<EOP
{
  my ($chans, $mesg) = (VIM::Eval('l:args') =~ /^(\S+)(?: (.+))?$/);

  foreach my $chan (split(/,/, $chans))
    {
      if (is_channel($chan))
	{
	  irc_send("PART %s%s", $chan, ($mesg ? " $mesg" : ""));
	}
    }
}
EOP
endfunction

function! s:Send_PING(comd, args)
  if !strlen(a:args) || s:IsChannel(a:args)
    return
  endif

  perl <<EOP
{
  ctcp_send(1, scalar(VIM::Eval('a:args')), "%s %d",
					    scalar(VIM::Eval('a:comd')),
					    time());
}
EOP
endfunction

function! s:Send_QUIT(comd, args)
  let mesg = strlen(a:args) ? a:args : s:partmsg
  let bufnum = s:GetBufNum_Server()
  if bufnum >= 0
    " Mark this buffer as dead so that the next /SERVER invocation can close
    " it
    call setbufvar(bufnum, 'dead', 1)
  endif

  perl <<EOP
{
  my $mesg = VIM::Eval('l:mesg');

  # $mesg itself already contains a leading colon
  irc_send("QUIT %s", $mesg);

  foreach my $cref (@{$Current_Server->{'chans'}})
    {
      vim_close_channel($cref->{'name'});
    }

  foreach my $chat (@{$Current_Server->{'chats'}})
    {
      vim_close_chat($chat->{'nick'}, $Current_Server->{'server'});
    }

  while (my $dcc = find_dccclient())
    {
      dcc_close($dcc);
    }

  $Current_Server->{'conn'} |= $CS_QUIT;
}
EOP
  call s:CloseBuf_Server()
endfunction

function! s:Send_NOTICE(comd, args)
  call s:SendMSG(a:comd, a:args)
endfunction

function! s:Send_PRIVMSG(comd, args)
  call s:SendMSG(a:comd, a:args)
endfunction

function! s:SendGlobally(comd, args)
  perl <<EOP
{
  my $save_cur = $Current_Server;

  foreach my $sref (@Servers)
    {
      if ($sref->{'conn'} & $CS_LOGIN)
	{
	  set_curserver($sref->{'sock'});
	  VIM::DoCommand('call s:Send_{a:comd}(a:comd, a:args)');
	}
    }
  set_curserver($save_cur->{'sock'});
}
EOP
endfunction

function! s:PreSendMSG(mesg)
  if !s:IsConnected(s:server)
    return s:PromptKey('Do /SERVER first to get connected', 'WarningMsg')
  endif

  let mesg = substitute(a:mesg, '^/\s*', '', '')
  if strlen(mesg)
    let target = strlen(b:query) ? b:query : b:channel
    if strlen(target)
      call s:SendMSG('PRIVMSG', target.' :'.mesg)
    else
      call s:PromptKey('You are not on a channel.', 'Error')
    endif
  endif
endfunction

function! s:SendMSG(comd, args)
  if !strlen(a:args)
    return
  endif

  perl <<EOP
{
  if (my ($chan, $mesg) = (VIM::Eval('a:args') =~ /^(\S+) :(.+)$/))
    {
      unless (index($chan, '='))  # DCC CHAT
	{
	  dcc_send_chat(substr($chan, 1), $mesg);
	}
      else
	{
	  my $priv;
	  my $comd = VIM::Eval('a:comd');
	  my $nick = $Current_Server->{'nick'};

	  unless ($comd)
	    {
	      $comd = 'PRIVMSG';
	    }
	  $priv = ($comd eq 'PRIVMSG');

	  irc_send("%s %s :%s", $comd, $chan, $mesg);

	  if (is_channel($chan))
	    {
	      irc_add_line($chan, "%s%s%s%s: %s",
				  ($priv ? '<' : '['),
				  find_nickprefix($nick, $chan),
				  $nick,
				  ($priv ? '>' : ']'),
				  $mesg);
	    }
	  else
	    {
	      irc_chat_line($chan, "%s%s%s: %s",
				    ($priv ? '<' : '['),
				    $nick,
				    ($priv ? '>' : ']'),
				    $mesg);
	    }
	}
    }
}
EOP
endfunction

function! s:DoSend(comd, args)
  perl <<EOP
{
  my $comd = VIM::Eval('a:comd');
  my $args = VIM::Eval('a:args');

  irc_send("%s%s", $comd, ($args ? " $args" : ""));
}
EOP
endfunction

function! s:PerlIRC()
  " Don't use strict
  " TODO: Put these things in separate files
  perl <<EOP

use Fcntl qw(O_RDONLY O_WRONLY O_CREAT O_EXCL O_APPEND O_TRUNC);

our @Servers;		# IRC servers
our $Current_Server;	# reference referring an element of @Servers
our %Clients;		# clients connected over dcc protocol
our ($RS, $WS);		# IO::Select object

our $From_Server;	# simple string value of the last sender's name@host

our ($ENC_VIM, $ENC_IRC);

# Connection state flags
our $CS_LOGIN = 0x01;	# successfully logged in
our $CS_RECON = 0x02;	# trying to reconnect (after disconnected by server)
our $CS_QUIT  = 0x04;	# user "/QUIT"ted

sub add_server
{
  my $sref =  { server	  => undef,
		port	  => 0,
		local	  => undef,
		sock	  => undef,
		conn	  => 0,
		info	  => 0,
		bufnum	  => -1,
		nick	  => undef,
		pass	  => undef,
		umode	  => undef,
		away	  => undef,
		motd	  => 0,
		chans	  => [],
		chats	  => [],
		timers	  => [],
		lastping  => time(),
		lastbuf   => undef
	      };

  push(@Servers, $sref);
  return $sref;
}

sub find_server
{
  my $server = shift;

  foreach my $sref (@Servers)
    {
      if ($server eq $sref->{'server'})
	{
	  return $sref;
	}
    }

  return undef;
}

sub set_connected
{
  if ($_[0])
    {
      # Leave the CS_RECON flag here.  It'll be used to supress motd message
      $Current_Server->{'conn'} &= ~$CS_QUIT;
      $Current_Server->{'conn'} |= $CS_LOGIN;
    }
  else
    {
      close_server($Current_Server);
    }
  $Current_Server->{'info'} |= $INFO_UPDATE;
}

sub close_server
{
  my $sref = shift;

  $sref->{'conn'}  &= ~$CS_LOGIN;
  $sref->{'motd'}   = 0;
  $sref->{'umode'}  = undef;
  $sref->{'lastbuf'}= undef;

  if ($sref->{'conn'} & $CS_QUIT)
    {
      $sref->{'timers'} = [];
    }

  conn_close($sref);
}

sub open_server
{
  my $sref = shift;

  if (conn_open($sref))
    {
      conn_watchin($sref);  # add it to IO::Select
      #$sref->{'local'} = $sref->{'sock'}->sockhost();
      login_server($sref);
      return 1;
    }
  else
    {
      irc_add_line('', "!: Could not establish connection: %s", $!);
      return 0;
    }
}

sub login_server
{
  my $sref = shift;

  if ($Current_Server != $sref)
    {
      $Current_Server = $sref;
    }

  if ($sref->{'pass'})
    {
      irc_send("PASS %s", $sref->{'pass'});
    }
  irc_send("NICK %s", $sref->{'nick'});
  irc_send("USER %s %s * :%s",
	    vim_getvar('s:user'),
	    vim_getvar('s:umode'),
	    vim_getvar('s:realname'));
}

sub post_login_server
{
  my $sref = shift;

  $sref->{'motd'} = 1;
  $sref->{'conn'} &= ~$CS_RECON;  # clear the "reconnecting" flag

  irc_send("USERHOST %s", $sref->{'nick'});

  if (my $umode = vim_getvar('s:umode'))
    {
      irc_send("MODE %s %s", $sref->{'nick'}, $umode);
    }

  if ($sref->{'away'})
    {
      irc_send("AWAY :%s", $sref->{'away'});
    }

  if (@{$sref->{'chans'}})
    {
      # Re-join channels
      foreach my $cref (@{$sref->{'chans'}})
	{
	  my $args = [ "JOIN %s%s", $cref->{'name'}, $cref->{'key'}
						      ? " $cref->{'key'}"
						      : "" ];
	  add_timer(2, \&irc_send, $args);
	}
    }
  else
    {
      # Wait 2 seconds so that you join channels (hopefully) after
      # auto-identifying the nick
      add_timer(2, \&do_auto_join);
    }
}

sub conn_close
{
  my $sref = shift;

  if ($sref->{'sock'})
    {
      $RS->remove($sref->{'sock'});

      if (defined($WS) && $WS->exists($sref->{'sock'}))
	{
	  $WS->remove($sref->{'sock'});
	}

      #$sref->{'sock'}->shutdown(2);
      $sref->{'sock'}->close();
    }
}

sub conn_open
{
  use IO::Socket;

  my $sref = shift;
  my $sock;

  if ($sref->{'server'} && $sref->{'port'})
    {
      $sock = IO::Socket::INET->new(PeerAddr  => $sref->{'server'},
				    PeerPort  => $sref->{'port'},
				    Proto     => 'tcp',
				    Timeout   => 10);
      if ($sock)
	{
	  $sref->{'sock'} = $sock;
	}
    }

  return defined($sock);
}

sub conn_watchin
{
  my $sref = shift;

  if (defined($sref->{'sock'}))
    {
      unless (defined($RS))
	{
	  use IO::Select;
	  $RS = IO::Select->new();
	}
      $RS->add($sref->{'sock'});
    }
}

sub conn_watchout
{
  my $sref = shift;

  if (defined($sref->{'sock'}))
    {
      unless (defined($WS))
	{
	  $WS = IO::Select->new();
	}
      $WS->add($sref->{'sock'});
    }
}

sub set_curserver
{
  my $sock = shift;

  foreach my $sref (@Servers)
    {
      if ($sock == $sref->{'sock'})
	{
	  $Current_Server = $sref;
	  VIM::DoCommand("let s:server = \"$sref->{'server'}\"");
	  last;
	}
    }
}

sub irc_add_line
{
  my $chan  = shift;
  my $cref  = is_channel($chan) ? find_channel($chan) : undef;
  my $format= shift;
  my $peek  = 0;
  my $orgbuf= VIM::Eval("bufnr('%')");

  if (is_channel($chan) && $cref)
    {
      unless (vim_visit_channel($chan))
	{
	  if ($peek = vim_getvar('s:singlewin'))
	    {
	      vim_peekbuf(1);

	      unless ($cref->{'info'} & $INFO_HASNEW)
		{
		  $cref->{'info'} |= $INFO_HASNEW;
		  $Current_Server->{'info'} |= $INFO_UPDATE;
		}
	    }
	  vim_open_channel($chan);
	}
    }
  else
    {
      $cref = $Current_Server;

      unless (vim_visit_server())
	{
	  if ($peek = vim_getvar('s:singlewin'))
	    {
	      vim_peekbuf(1);

	      unless ($cref->{'info'} & $INFO_HASNEW)
		{
		  $cref->{'info'} |= ($INFO_HASNEW | $INFO_UPDATE);
		}
	    }
	  vim_open_server();
	}
    }

  if ($cref->{'bufnum'} < 0)
    {
      # I sometimes see this fail
      if (my $bufnum = VIM::Eval("bufnr('%')"))
	{
	  $cref->{'bufnum'} = $bufnum;

	  unless ($Current_Server->{'info'} & $INFO_UPDATE)
	    {
	      $Current_Server->{'info'} |= $INFO_UPDATE;
	    }
	}
    }

  vim_bufmodify(1);
  $curbuf->Append($curbuf->Count(), sprintf("%s $format", vim_gettime(1), @_));
  vim_bufmodify(0);

  if ($peek)
    {
      vim_peekbuf(0);
    }
  elsif (!$Current_Server->{'away'})
    {
      # Shouldn't scroll down nor beep while you're away
      vim_notifyentry();
    }
  vim_selectwin($orgbuf);
  vim_redraw();
}

sub irc_chat_line
{
  my $nick  = shift;
  my $format= shift;
  my $chat  = find_chat($nick, $Current_Server);
  my $peek  = 0;
  my $orgbuf= VIM::Eval("bufnr('%')");

  unless ($chat)
    {
      $chat = add_chat($nick, $Current_Server);
    }

  unless (vim_visit_chat($nick, $Current_Server->{'server'}))
    {
      if ($peek = vim_getvar('s:singlewin'))
	{
	  vim_peekbuf(1);

	  unless ($chat->{'info'} & $INFO_HASNEW)
	    {
	      $chat->{'info'} |= $INFO_HASNEW;
	      $Current_Server->{'info'} |= $INFO_UPDATE;
	    }
	}
      vim_open_chat($nick, $Current_Server->{'server'});
    }

  if ($chat->{'bufnum'} < 0)
    {
      if ($bufnum = VIM::Eval("bufnr('%')"))
	{
	  $chat->{'bufnum'} = $bufnum;

	  unless ($chat->{'info'} & $INFO_UPDATE)
	    {
	      $chat->{'info'} |= $INFO_UPDATE;
	    }
	}
    }
  vim_bufmodify(1);
  $curbuf->Append($curbuf->Count(), sprintf("%s $format", vim_gettime(1), @_));
  vim_bufmodify(0);

  if ($peek)
    {
      vim_peekbuf(0);
    }
  elsif (!$Current_Server->{'away'})
    {
      # Shouldn't scroll down nor beep while you're away
      vim_notifyentry();
    }
  vim_selectwin($orgbuf);
  vim_redraw();
}

sub irc_recv
{
  my $sock = shift;
  my ($buffer, @lines);

  set_curserver($sock);

  unless (sysread($sock, $buffer, 2048))
    {
      set_connected(0);

      unless ($Current_Server->{'conn'} & $CS_QUIT)
	{
	  $Current_Server->{'conn'} |= $CS_RECON;
	  irc_add_line('', "!: Connection with %s lost",
						  $Current_Server->{'server'});
	  irc_add_line('', "*: Reconnecting...");

	  if (open_server($Current_Server))
	    {
	      return 1;
	    }
	}
      return 0;
    }

  if ($Current_Server->{'lastbuf'})
    {
      $buffer = $Current_Server->{'lastbuf'}.$buffer;
      $Current_Server->{'lastbuf'} = undef;
    }

  @lines = split(/\x0D?\x0A/, $buffer);
  if (substr($buffer, -1) ne "\x0A")
    {
      # Data obtained partially. Save the last line for later use
      $Current_Server->{'lastbuf'} = pop(@lines);
    }

  foreach my $line (@lines)
    {
      if ($ENC_VIM && $ENC_IRC)
	{
	  Encode::from_to($line, $ENC_IRC, $ENC_VIM);
	}
      if (0)
	{
	  vim_printf($line);
	}
      parse_line(\$line);
    }

  return 1;
}

sub irc_send
{
  my $format = shift;
  my @args = @_;

  if ($ENC_VIM && $ENC_IRC)
    {
      foreach my $arg (@args)
	{
	  Encode::from_to($arg, $ENC_VIM, $ENC_IRC);
	}
    }
  syswrite($Current_Server->{'sock'}, sprintf("$format\x0D\x0A", @args));
}

#
# Infobar
#

our $INFO_UPDATE = 0x01;
our $INFO_HASNEW = 0x02;

sub update_info
{
  my $orgbuf = VIM::Eval("bufnr('%')");

  if (vim_open_info())
    {
      my $orglin = VIM::Eval("line('.')");

      vim_bufmodify(1);
      $curbuf->Delete(1, $curbuf->Count());

      foreach my $sref (@Servers)
	{
	  my $dead = !($sref->{'conn'} & $CS_LOGIN);

	  $curbuf->Append($curbuf->Count(),
			  sprintf("%s[%d]%s",
				  $dead
				  ? '-'
				  : $sref->{'info'} & $INFO_HASNEW
				    ? '+' : ' ',
				  $sref->{'bufnum'},
				  $sref->{'server'}));

	  foreach my $cref (@{$sref->{'chans'}})
	    {
	      $curbuf->Append($curbuf->Count(),
			      sprintf(" %s[%d]%s\t\t\t%s",
				      $dead
				      ? '-'
				      : $cref->{'info'} & $INFO_HASNEW
					? '+' : ' ',
				      $cref->{'bufnum'},
				      $cref->{'name'},
				      $sref->{'server'}));
	    }

	  foreach my $chat (@{$sref->{'chats'}})
	    {
	      $curbuf->Append($curbuf->Count(),
			      sprintf(" %s[%d]%s\t\t\t%s",
				      $dead && index($chat->{'nick'}, '=')
				      ? '-'
				      : $chat->{'info'} & $INFO_HASNEW
					? '+' : ' ',
				      $chat->{'bufnum'},
				      $chat->{'nick'},
				      $sref->{'server'}));
	    }

	  $sref->{'info'} &= ~$INFO_UPDATE;
	}

      $curbuf->Delete(1);
      if ($orglin)
	{
	  $curwin->Cursor($orglin, 0);
	}
      vim_bufmodify(0);
      vim_selectwin($orgbuf);
    }
}

#
# Timer
#

sub add_timer
{
  my ($secs, $func, $args) = @_;
  my $timer;

  if (my $timers = $Current_Server->{'timers'})
    {
      $timer =	{ time => time() + $secs,
		  func => $func,
		  args => $args,
		  done => 0
		};
      push(@{$timers}, $timer);
    }

  return $timer;
}

sub del_timer
{
  foreach my $sref (@Servers)
    {
      for (my $i = 0; $i <= $#{$sref->{'timers'}}; $i++)
	{
	  if ($sref->{'timers'}->[$i]->{'done'})
	    {
	      splice(@{$sref->{'timers'}}, $i--, 1);
	    }
	}
    }
}

sub do_timer
{
  my $time = shift;
  my $did  = 0;

  foreach my $sref (@Servers)
    {
      if ($sref->{'conn'} & $CS_LOGIN)
	{
	  # $Current_Server has to be restored by the caller
	  $Current_Server = $sref;

	  do_auto_ping($sref, $time);
	  if (!$sref->{'away'} && vim_getvar('s:autoaway'))
	    {
	      do_auto_away($sref, $time);
	    }

	  foreach my $timer (@{$sref->{'timers'}})
	    {
	      if ($timer->{'time'} <= $time)
		{
		  $timer->{'func'}(@{$timer->{'args'}});
		  $timer->{'done'} = 1;
		  $did++;
		}
	    }
	}

      if (vim_getvar('s:singlewin') && ($sref->{'info'} & $INFO_UPDATE))
	{
	  update_info();
	}
    }

  if ($did)
    {
      del_timer();
    }
}

sub do_auto_away
{
  my ($sref, $time) = @_;
  my $lastactive = vim_getvar('s:lastactive');

  if ($time >= $lastactive + vim_getvar('s:autoawaytime'))
    {
      irc_add_line('', "*: Auto-awaying...");
      $sref->{'away'} = sprintf("I think I'm gone (been idle since %s).",
						vim_gettime(0, $lastactive));
      irc_send("AWAY :%s", $sref->{'away'});
    }
}

# Play ping-pong with servers to keep connected
sub do_auto_ping
{
  my ($sref, $time) = @_;

  if ($time >= $sref->{'lastping'} + 90)
    {
      irc_send("PING %d", $time);
      $sref->{'lastping'} = $time;
    }
}

sub do_auto_join
{
  if (my $autojoin = vim_getvar('g:vimirc_autojoin'))
    {
      if (my @chans = split(/,/, $autojoin))
	{
	  if (index($chans[0], '@') > 0)
	    {
	      # Format: #chan1@irc.foo.com,$chan2|$chan3@irc.bar.com
	      foreach my $chans (@chans)
		{
		  if (($chans) = ($chans
				    =~ /^(\S+)\@$Current_Server->{'server'}$/))
		    {
		      $chans =~ s/\|(?=[&#+!])/,/g;
		      VIM::DoCommand('call s:Send_JOIN("JOIN",
			    \			  "'.do_escape($chans).'")');
		      last;
		    }
		}
	    }
	  else
	    {
	      # Format: #chan2,#chan2
	      VIM::DoCommand("call s:Send_JOIN('JOIN', g:vimirc_autojoin)");
	    }
	}
    }
}

#
# CTCP
#

# Heavily based on ircii and x-chat, regarding the DCC part.

our @DCC_TYPES = qw(. GET SEND CHAT CHAT);

our $DCC_FILERECV = 0x01;
our $DCC_FILESEND = 0x02;
our $DCC_CHATRECV = 0x03;
our $DCC_CHATSEND = 0x04;
our $DCC_TYPE	  = 0x0f;

our $DCC_RESUME	  = 0x10;
our $DCC_QUEUED	  = 0x20;
our $DCC_ACTIVE	  = 0x40;
our $DCC_FAILED	  = 0x80;

our $DCC_BLOCK_SIZE = 2048;

sub ctcp_send
{
  # TODO: Follow the rules described in:
  #   "REVISED AND UPDATED CTCP SPECIFICATION"
  #   Dated Fri, 12 Aug 94 00:21:54 edt
  #   By ben@gnu.ai.mit.edu et al.
  my $query = shift;
  my $target= shift;

  irc_send("%s %s :\x01%s\x01", ($query ? 'PRIVMSG' : 'NOTICE'), $target,
						      sprintf(shift(@_), @_));
}

sub ctcp_query_action
{
  my ($from, $pref, $chan, $mesg) = @_;

  if (is_channel($chan))
    {
      irc_add_line($chan, "*%s%s*: %s", $pref, $from, ${$mesg});
    }
  elsif (is_me($chan))
    {
      irc_chat_line($from, "*%s*: %s", $from, ${$mesg});
      unless ($Current_Server->{'away'})
	{
	  vim_beep(1);
	}
    }
}

sub ctcp_query_clientinfo
{
  my ($from, $comd, $args) = @_;
  our %info;

  unless (defined(%info))
    {
      %info = (
	     CLIENTINFO => 'gives information about available CTCP commands',
		ECHO	=> 'returns arguments you send',
		PING	=> 'returns arguments you send',
		TIME	=> 'tells you the time on my side',
		VERSION => 'shows client type and version'
	      );
    }

  unless ($args)
    {
      ctcp_send(0, $from, "%s %s. Use %s <COMMAND> to get more specific
			\ information", $comd, join(' ', keys(%info)), $comd);
    }
  else
    {
      $args = uc($args);

      if (exists($info{$args}))
	{
	  ctcp_send(0, $from, "%s %s", $comd, $info{$args});
	}
      else
	{
	  ctcp_send(0, $from, "%s No such function implemented: %s",
								$comd, $args);
	}
    }
}

sub ctcp_query_echo
{
  ctcp_send(0, $_[0], "%s %s", $_[1], $_[2]);
}

sub ctcp_query_ping
{
  ctcp_send(0, $_[0], "%s %s", $_[1], $_[2]);
}

sub ctcp_query_time
{
  ctcp_send(0, $_[0], "%s %s", $_[1], vim_gettime(0));
}

sub ctcp_query_version
{
  ctcp_send(0, $_[0], "%s %s", $_[1], vim_getvar('s:client'));
}

sub process_ctcp_query
{
  my ($from, $pref, $chan, $mesg) = @_;

  while (${$mesg} =~ s/\x01(.*?)\x01//)
    {
      # TODO: flood-protection codes here
      if (my ($comd, $args) = ($1 =~ /^(\S+)(?:\s+(.+))?$/))
	{
	  if ($comd eq 'DCC')
	    {
	      if (is_me($chan))   # is this check necessary?
		{
		  process_dcc_query($from, $args);
		}
	    }
	  elsif ($comd eq 'ACTION')
	    {
	      ctcp_query_action($from, $pref, $chan, \$args);
	    }
	  else
	    {
	      my $func = 'ctcp_query_'.lc($comd);

	      irc_add_line($chan, "?%s%s(CTCP)?: %s %s", $pref, $from, $comd,
									$args);

	      if (defined(&{$func}))
		{
		  &{$func}($from, $comd, $args);
		}
	      else
		{
		  if (is_me($chan))
		    {
		      ctcp_send(0, $from, "ERRMSG %s: unknown query", $comd);
		    }
		  irc_add_line('', "!: CTCP query from %s unprocessed: %s",
								$from, $comd);
		}
	    }
	}
    }

  return length(${$mesg});
}

sub process_ctcp_reply
{
  my ($from, $chan, $mesg) = @_;

  if (${$mesg} =~ s/\x01(.*?)\x01//)
    {
      if (my ($comd, $args) = ($1 =~ /^(\S+)(?:\s+(.+))?$/))
	{
	  if ($comd eq 'DCC')
	    {
	      if (is_me($chan))
		{
		  process_dcc_reply($from, $args);
		}
	    }
	  elsif ($comd eq 'PING')
	    {
	      my $diff = time() - $args;
	      irc_add_line('', "[%s(%s)]: %d second%s delay",
				$from, $comd, $diff, ($diff != 1 ? 's' : ''));
	    }
	  else
	    {
	      irc_add_line('', "[%s(%s)]: %s", $from, $comd, $args);
	    }
	}
    }
  return length(${$mesg});
}

sub process_dcc_query
{
  my ($from, $args) = @_;

  if (1)
    {
      irc_add_line('', "?%s(DCC)?: %s", $from, $args);
    }

  # Hope no one includes spaces in filenames
  if (my ($type, $desc, $server, $port, $size) =
		    ($args =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\d+)(?:\s+(\d+))?$/))
    {
      my $dcc;

      if ($type eq 'RESUME')
	{
	  # NOTE: resumes don't have a `server' part
	  dcc_they_resume($from, $desc, $server, $port);
	  return;
	}
      elsif ($type eq 'ACCEPT')
	{
	  dcc_i_resume($from, $desc, $server, $port);
	  return;
	}

      # TODO: IPv6
      if (index($server, '.') <= 0)   # XXX: could it be in dotted-quad form?
	{
	  $server = inet_ntoa(pack('N', $server));
	}

      if ($type eq 'CHAT')
	{
	  $dcc = find_dccclient($from, $DCC_CHATRECV);
	  if ($dcc)
	    {
	      dcc_close($dcc);
	    }
	  $dcc = find_dccclient($from, $DCC_CHATSEND);
	  if ($dcc)
	    {
	      dcc_close($dcc);
	    }

	  $dcc = add_dccclient();
	  if ($dcc)
	    {
	      $dcc->{'nick'}  = $from;
	      $dcc->{'server'}= $server;
	      $dcc->{'port'}  = $port;
	      $dcc->{'flags'} = $DCC_CHATRECV;
	      $dcc->{'desc'}  = $desc;
	    }
	}
      elsif ($type eq 'SEND')
	{
	  $dcc = find_dccclient($from, $DCC_FILERECV, $desc);
	  if ($dcc)
	    {
	      return;
	    }

	  $dcc = add_dccclient();
	  if ($dcc)
	    {
	      my $dccdir = vim_getvar('s:dccdir');
	      my ($fname)= ($desc =~ m#^(?:.*/)?(.+)$#);

	      $dcc->{'nick'}  = $from;
	      $dcc->{'server'}= $server;
	      $dcc->{'port'}  = $port;
	      $dcc->{'flags'} = $DCC_FILERECV;
	      $dcc->{'desc'}  = $desc;
	      $dcc->{'fname'} = sprintf("%s/%s", $dccdir, do_urldecode($fname));
	      $dcc->{'fsize'} = $size;

	      # FIXME: Currently turning off the RESUME: append seems to
	      # corrupt data
	      if (0 && -e $dcc->{'fname'})
		{
		  if ((my $fsize = (-s $dcc->{'fname'})) < $size)
		    {
		      # Need confirmation?
		      $dcc->{'flags'} |= ($DCC_RESUME | $DCC_QUEUED);
		      $dcc->{'bytesread'} = $fsize;
		      ctcp_send(1, $dcc->{'nick'}, "DCC RESUME %s %d %d",
						    $desc, $port, $fsize);
		      return;
		    }
		}
	    }
	}
      else
	{
	  irc_add_line('', "DCC: Query from %s unprocessed: %s", $from, $args);
	  ctcp_send(0, $from, "DCC REJECT %s %s", $type, $desc);
	}

      if ($dcc)
	{
	  $dcc->{'flags'} |= $DCC_QUEUED;
	  dcc_open($dcc);
	}
    }
}

sub process_dcc_reply
{
  my ($from, $args) = @_;

  if (my ($type, $desc) = ($args =~ /^(\S+)\s+(.+)$/))
    {
      dcc_was_rejected($from, uc($type), $desc);
    }
  else
    {
      irc_add_line('', "DCC: Reply from %s: %s", $from, $args);
    }
}

sub dcc_ask_accept_offer
{
  my $dcc  = shift;
  my $mesg = sprintf("%s is offering DCC %s to you.  Accept it?",
		      $dcc->{'nick'},
		      (($dcc->{'flags'} & $DCC_TYPE) == $DCC_FILERECV
			? 'SEND'
			: $DCC_TYPES[$dcc->{'flags'} & $DCC_TYPE]));

  vim_beep(2);
  return vim_getconf($mesg);
}

sub dcc_show_list
{
  irc_add_line('', "*: Listing DCC sessions...");

  foreach my $sref (@Servers)
    {
      if (exists($Clients{$sref->{'server'}})
	  && @{$Clients{$sref->{'server'}}})
	{
	  irc_add_line('', "DCC(LIST): * Via %s:", $sref->{'server'});
	  foreach my $dcc (@{$Clients{$sref->{'server'}}})
	    {
	      irc_add_line('', "DCC(LIST): %-5s %-10.10s (%s) %7u/%-7u %s",
				$DCC_TYPES[$dcc->{'flags'} & $DCC_TYPE],
				$dcc->{'nick'},
				(($dcc->{'flags'} & $DCC_ACTIVE)
				  ? 'active'
				  : ($dcc->{'flags'} & $DCC_QUEUED)
				    ? 'queued'
				    : 'closed'),
				($dcc->{'bytessent'}
				  ? $dcc->{'bytessent'}
				  : $dcc->{'bytesread'}),
				$dcc->{'fsize'},
				$dcc->{'fname'});
	    }
	}
    }
  irc_add_line('', "End of /DCC LIST");
}

sub dcc_was_rejected
{
  my ($nick, $type, $desc) = @_;

  for (my $i = 1; $i < $#DCC_TYPES; $i++)
    {
      if ($type eq $DCC_TYPES[$i])
	{
	  $type = $i;
	}
    }

  unless ($type & $DCC_TYPE)
    {
      return;
    }

  if (my $dcc = find_dccclient($nick, $type, $desc))
    {
      irc_add_line('', "DCC(%s): Offering %s to %s was rejected",
			$DCC_TYPES[$dcc->{'flags'} & $DCC_TYPE],
			$desc,
			$nick);
      dcc_close($dcc);
    }
}

sub dcc_change_nick
{
  my ($old, $new) = @_;

  while (my $dcc = find_dccclient($old))
    {
      $dcc->{'nick'} = $new;
    }
}

sub dcc_chat_line
{
  my ($dcc, $itsme) = @_;
  my $chat = find_chat("=$dcc->{'nick'}", $dcc->{'iserver'});
  my $peek = 0;
  my $orgbuf = VIM::Eval("bufnr('%')");

  unless (vim_visit_chat("=$dcc->{'nick'}", $dcc->{'iserver'}->{'server'}))
    {
      if ($peek = vim_getvar('s:singlewin'))
	{
	  vim_peekbuf(1);

	  if ($chat && !($chat->{'info'} & $INFO_HASNEW))
	    {
	      $chat->{'info'} |= $INFO_HASNEW;
	      $dcc->{'iserver'}->{'info'} |= $INFO_UPDATE;
	    }
	}
      vim_open_chat("=$dcc->{'nick'}", $dcc->{'iserver'}->{'server'});
    }

  if ($chat->{'bufnum'} < 0)
    {
      if ($bufnum = VIM::Eval("bufnr('%')"))
	{
	  $chat->{'bufnum'} = $bufnum;

	  unless ($dcc->{'iserver'}->{'info'} & $INFO_UPDATE)
	    {
	      $dcc->{'iserver'}->{'info'} |= $INFO_UPDATE;
	    }
	}
    }
  vim_bufmodify(1);

  foreach my $line (split(/\x0D?\x0A/, $dcc->{'linebuf'}))
    {
      my $action = ($line =~ s/^\x01ACTION (.*?)\x01/$1/);

      if ($ENC_VIM && $ENC_IRC)
	{
	  Encode::from_to($mesg, $ENC_IRC, $ENC_VIM);
	}
      $curbuf->Append($curbuf->Count(),
		      sprintf("%s %s%s%s: %s",
			      vim_gettime(1),
			      ($action ? '*' : '='),
			      ($itsme
				? $dcc->{'iserver'}->{'nick'}
				: $dcc->{'nick'}),
			      ($action ? '*' : '='),
			      $line));
    }
  vim_bufmodify(0);

  if ($peek)
    {
      vim_peekbuf(0);
    }
  elsif (!$Current_Server->{'away'})
    {
      vim_notifyentry();
    }

  unless ($Current_Server->{'away'} || $itsme)
    {
      vim_beep(1);
    }
  vim_selectwin($orgbuf);
  vim_redraw();
}

sub add_dccclient
{
  # To avoid nick collisions, we hold dcc clients on server basis
  my $server = $Current_Server->{'server'};
  my $dcc = { nick	=> undef,
	      iserver	=> $Current_Server,
	      server	=> undef,
	      port	=> 0,
	      sock	=> undef,
	      flags	=> 0,
	      desc	=> undef,
	      fh	=> undef,
	      fname	=> undef,
	      fsize	=> 0,
	      linebuf	=> undef,
	      lastbuf	=> undef,
	      bytesread => 0,
	      bytessent => 0,
	      starttime => 0,
	      lasttime	=> 0
	    };

  unless (exists($Clients{$server}))
    {
      $Clients{$server} = [];
    }

  unshift(@{$Clients{$server}}, $dcc);
  return $dcc;
}

sub find_dccclient_fd
{
  my $sock = shift;

  foreach my $sref (@Servers)
    {
      if (exists($Clients{$sref->{'server'}}))
	{
	  foreach my $dcc (@{$Clients{$sref->{'server'}}})
	    {
	      if ($sock == $dcc->{'sock'})
		{
		  return $dcc;
		}
	    }
	}
    }

  return undef;
}

sub find_dccclient
{
  # An empty argument will be used as a wildcard (i.e., matches anything)
  # NOTE: Only searches for a client on the current IRC server, since this
  #	  will only be called upon queries via that server
  my ($nick, $type, $desc) = @_;

  foreach my $dcc (@{$Clients{$Current_Server->{'server'}}})
    {
      if ($dcc->{'flags'} & $DCC_FAILED)  # do not return closed/rejected one
	{
	  next;
	}
      if ($nick && $dcc->{'nick'} ne $nick)
	{
	  next;
	}
      if ($type && ($dcc->{'flags'} & $DCC_TYPE) != $type)
	{
	  next;
	}
      if ($desc && $dcc->{'desc'} ne $desc)
	{
	  next;
	}
      return $dcc;
    }

  return undef;
}

sub del_dccclient
{
  my $dcc = shift;

  foreach my $sref (@Servers)
    {
      if (exists($Clients{$sref->{'server'}}))
	{
	  my $clients = $Clients{$sref->{'server'}};

	  for (my $i = 0; $i <= $#{$clients}; $i++)
	    {
	      if ($dcc == $clients->[$i])
		{
		  splice(@{$clients}, $i, 1);
		  return;
		}
	    }
	}
    }
}

sub dcc_init_listen
{
  my $dcc  = shift;
  # local address in unsigned long integer
  my $local= unpack('N', inet_aton($Current_Server->{'local'}));
  # port to watch at (normally 0)
  my $port = vim_getvar('s:dccport') + 0;
  my $ctcp;

  # Open up a listening socket
  $dcc->{'sock'} = IO::Socket::INET->new( LocalAddr => undef,
					  LocalPort => $port,
					  Proto	    => 'tcp',
					  Listen    => 1,
					  ReuseAddr => 1    );
  unless ($dcc->{'sock'})
    {
      del_dccclient($dcc);
      irc_add_line('', "DCC(%s): Failed in opening socket: %s",
			$DCC_TYPES[$dcc->{'flags'} & $DCC_TYPE], $!);
      return;
    }

  $dcc->{'port'} = $port ? $port : $dcc->{'sock'}->sockport();

  if (($dcc->{'flags'} & $DCC_TYPE) == $DCC_FILESEND)
    {
      ctcp_send(1, $dcc->{'nick'}, "DCC %s %s %lu %u %ld",
				    $DCC_TYPES[$dcc->{'flags'} & $DCC_TYPE],
				    $dcc->{'desc'},
				    $local,
				    $dcc->{'port'},
				    $dcc->{'fsize'});
    }
  else
    {
      ctcp_send(1, $dcc->{'nick'}, "DCC %s chat %lu %u",
				    $DCC_TYPES[$dcc->{'flags'} & $DCC_TYPE],
				    $local,
				    $port);
    }
  conn_watchin($dcc);
}

sub dcc_i_accept
{
  my $dcc  = shift;
  my $sock = $dcc->{'sock'}->accept();

  unless ($sock)
    {
      irc_add_line('', "DCC(%s): Could not accept incoming connect from %s: %s",
			$DCC_TYPES[$dcc->{'flags'} & $DCC_TYPE],
			$dcc->{'nick'},
			$!);
      dcc_close($dcc);
      return;
    }

  conn_close($dcc);
  #$sock->sockopt(SO_SNDLOWAT, $DCC_BLOCK_SIZE);
  $dcc->{'sock'} = $sock;
  $dcc->{'server'} = $sock->peerhost();
  conn_watchin($dcc);
  $dcc->{'flags'} &= ~$DCC_QUEUED;
  $dcc->{'flags'} |= $DCC_ACTIVE;

  irc_add_line('', "DCC(%s): Connection with %s established",
		    $DCC_TYPES[$dcc->{'flags'} & $DCC_TYPE],
		    $dcc->{'nick'});

  if (($dcc->{'flags'} & $DCC_TYPE) == $DCC_FILESEND)
    {
      # FIXME: it blocks
      #conn_watchout($dcc);
      dcc_send_file($dcc);
    }
  elsif (($dcc->{'flags'} & $DCC_TYPE) == $DCC_CHATSEND)
    {
      # Drop the `send' flag off
      $dcc->{'flags'} = ($DCC_CHATRECV | $DCC_ACTIVE);
    }

  if (($dcc->{'flags'} & $DCC_TYPE) == $DCC_CHATRECV)
    {
      add_chat("=$dcc->{'nick'}", $dcc->{'iserver'});
    }
}

sub dcc_they_accept
{
  my $dcc = shift;

  if (conn_open($dcc))
    {
      $dcc->{'flags'} &= ~$DCC_QUEUED;
      $dcc->{'flags'} |= $DCC_ACTIVE;

      if (($dcc->{'flags'} & $DCC_TYPE) == $DCC_CHATRECV)
	{
	  add_chat("=$dcc->{'nick'}", $dcc->{'iserver'});
	}

      conn_watchin($dcc);
    }
  else
    {
      irc_add_line('', "DCC(%s): Could not initialize connection with %s: %s",
			$DCC_TYPES[$dcc->{'flags'} & $DCC_TYPE],
			$dcc->{'nick'}, $!);
      del_dccclient($dcc);
    }
}

sub dcc_open
{
  my $dcc = shift;

  unless ($dcc->{'flags'})
    {
      # Huh?
      del_dccclient($dcc);
      return;
    }

  if (	 (($dcc->{'flags'} & $DCC_TYPE) == $DCC_FILESEND)
      || (($dcc->{'flags'} & $DCC_TYPE) == $DCC_CHATSEND))
    {
      dcc_init_listen($dcc);
    }
  else
    {
      if (($dcc->{'flags'} & $DCC_RESUME) || dcc_ask_accept_offer($dcc))
	{
	  dcc_they_accept($dcc);
	}
    }
}

sub dcc_close
{
  my ($dcc, $destroy) = @_;

  conn_close($dcc);

  if ($dcc->{'fh'})
    {
      close($dcc->{'fh'});
    }

  # XXX: Delete it by default?  Or should we wait a few seconds?
  if (!defined($destroy) || $destroy)
    {
      if (   (($dcc->{'flags'} & $DCC_TYPE) == $DCC_CHATRECV)
	  || (($dcc->{'flags'} & $DCC_TYPE) == $DCC_CHATSEND))
	{
	  vim_close_chat("=$dcc->{'nick'}", $dcc->{'iserver'}->{'server'});
	  del_chat("=$dcc->{'nick'}", $dcc->{'iserver'});
	}
      del_dccclient($dcc);
    }
  else
    {
      $dcc->{'flags'} &= ~$DCC_ACTIVE;
    }
}

sub dcc_i_resume
{
  my ($nick, $desc, $port, $resume) = @_;
  my $dcc = find_dccclient($nick, $DCC_FILERECV, $desc);

  if ($dcc && ($dcc->{'flags'} & $DCC_QUEUED))
    {
      dcc_open($dcc);
    }
}

sub dcc_they_resume
{
  my ($nick, $desc, $port, $resume) = @_;
  my $dcc = find_dccclient($nick, $DCC_FILESEND, $desc);

  if ($dcc && ($dcc->{'port'} == $port) && ($resume < $dcc->{'fsize'}))
    {
      $dcc->{'bytessent'} = $resume;
      ctcp_send(1, $dcc->{'nick'}, "DCC ACCEPT %s %d %d", $desc, $port,
								    $resume);
    }
}

sub dcc_recv_file
{
  my $dcc = shift;
  my ($buffer, $bytesread);

  unless ($dcc->{'fh'})
    {
      my $dccdir = vim_getvar('s:dccdir');

      unless (my_mkdir($dccdir))
	{
	  irc_add_line('', "DCC(GET): Could not create download directory: %s",
									  $!);
	  dcc_close($dcc);
	  return;
	}

      if ($dcc->{'flags'} & $DCC_RESUME)
	{
	  sysopen($dcc->{'fh'}, $dcc->{'fname'}, O_BINARY|O_WRONLY|O_APPEND);
	}
      else
	{
	  if (-e $dcc->{'fname'})
	    {
	      my $n = 0;
	      my $newname = $dcc->{'fname'};
	      while (-e $newname)
		{
		  $newname = sprintf("%s.%d", $dcc->{'fname'}, ++$n);
		}
	      $dcc->{'fname'} = $newname;
	      irc_add_line('', "DCC(GET): File already exists.
				\  Saving it as %s", $newname);
	    }
	  sysopen($dcc->{'fh'}, $dcc->{'fname'},
					    O_BINARY|O_WRONLY|O_EXCL|O_CREAT);
	}

      unless ($dcc->{'fh'})
	{
	  irc_add_line('', "DCC(GET): Could not open file %s for writing:
			    \ %s", $dcc->{'fname'}, $!);
	  dcc_close($dcc);
	  return;
	}
    }

  unless ($bytesread = sysread($dcc->{'sock'}, $buffer, $DCC_BLOCK_SIZE))
    {
      if ($dcc->{'bytesread'} < $dcc->{'fsize'})
	{
	  irc_add_line('', "DCC(GET): Connection with %s lost", $dcc->{'nick'});
	}
      dcc_close_filetransfer($dcc);
    }
  else
    {
      unless (syswrite($dcc->{'fh'}, $buffer, $bytesread))  # hdd full?
	{
	  irc_add_line('', "DCC(GET): Failed in writing to file: %s", $!);
	  dcc_close($dcc);
	}
      else
	{
	  # Notify the progress to the peer
	  $dcc->{'bytesread'} += $bytesread;
	  unless (syswrite($dcc->{'sock'}, pack('N', $dcc->{'bytesread'}), 4))
	    {
	      irc_add_line('', "DCC(GET): Connection with %s lost",
							      $dcc->{'nick'});
	      dcc_close($dcc);
	    }
	}
    }
}

sub dcc_recv_ack
{
  my $dcc = shift;
  my $ack;

  if (sysread($dcc->{'sock'}, $ack, 4) < 4)
    {
      irc_add_line('', "DCC(SEND): Connection with %s lost", $dcc->{'nick'});
      dcc_close($dcc);
    }
  else
    {
      if ($dcc->{'bytessent'} >= $dcc->{'fsize'})
	{
	  if (unpack('N', $ack) >= $dcc->{'fsize'})
	    {
	      dcc_close_filetransfer($dcc);
	    }
	}
      else
	{
	  dcc_send_file($dcc);
	}
    }
}

sub dcc_send_file
{
  my $dcc = shift;
  my ($buffer, $bytesread);

  unless ($dcc->{'fh'})
    {
      if (sysopen($dcc->{'fh'}, $dcc->{'fname'}, O_BINARY|O_RDONLY))
	{
	  if ($dcc->{'bytessent'})
	    {
	      use Fcntl qw(SEEK_SET);
	      sysseek($dcc->{'fh'}, $dcc->{'bytessent'}, SEEK_SET);
	    }
	}
      else
	{
	  irc_add_line('', "DCC(SEND): Could not open file for reading: %s",
									  $!);
	  dcc_close($dcc);
	  return;
	}
    }

  if ($bytesread = sysread($dcc->{'fh'}, $buffer, $DCC_BLOCK_SIZE))
    {
      # FIXME: It blocks if called via $WS
      if (syswrite($dcc->{'sock'}, $buffer, $bytesread) < $bytesread)
	{
	  irc_add_line('', "DCC(SEND): Connection with %s lost",
							    $dcc->{'nick'});
	  dcc_close($dcc);
	}
      else
	{
	  $dcc->{'bytessent'} += $bytesread;
	}
    }
}

sub dcc_close_filetransfer
{
  my $dcc = shift;

  irc_add_line('', "DCC(%s): Transfer of %s with %s completed (%d/%d)",
		    $DCC_TYPES[$dcc->{'flags'} & $DCC_TYPE],
		    $dcc->{'desc'},
		    $dcc->{'nick'},
		    ($dcc->{'bytessent'}
		      ? $dcc->{'bytessent'}
		      : $dcc->{'bytesread'}),
		    $dcc->{'fsize'});
  dcc_close($dcc);
}

sub dcc_recv_chat
{
  my $dcc = shift;

  if (my $bytesread = sysread($dcc->{'sock'}, $dcc->{'linebuf'}, 1024))
    {
      $dcc->{'bytesread'} += $bytesread;

      if ($dcc->{'lastbuf'})
	{
	  $dcc->{'linebuf'} = $dcc->{'lastbuf'}.$dcc->{'linebuf'};
	  $dcc->{'lastbuf'} = undef;
	}

      if (substr($dcc->{'linebuf'}, -1) ne "\x0A")
	{
	  # irssi sends "\n" separately after sending a message line.  Why?
	  $dcc->{'lastbuf'} = $dcc->{'linebuf'};
	}
      else
	{
	  dcc_chat_line($dcc);
	}
    }
  else
    {
      irc_add_line('', "DCC(CHAT): Connection with %s lost", $dcc->{'nick'});
      dcc_close($dcc);
    }
}

sub dcc_send_chat
{
  my ($nick, $mesg) = @_;
  my $dcc = find_dccclient($nick, $DCC_CHATRECV);

  if ($dcc->{'flags'} & $DCC_ACTIVE)
    {
      if ($ENC_VIM && $ENC_IRC)
	{
	  Encode::from_to($mesg, $ENC_VIM, $ENC_IRC);
	}

      $dcc->{'linebuf'} = sprintf("%s\x0D\x0A", $mesg);
      if (my $bytessent = syswrite($dcc->{'sock'}, $dcc->{'linebuf'}))
	{
	  $dcc->{'bytessent'} += $bytessent;
	  dcc_chat_line($dcc, 1);
	}
    }
}

sub dcc_check
{
  my ($sock, $write) = @_;
  my $dcc = find_dccclient_fd($sock);

  unless ($dcc)
    {
      return 0;
    }

  if ($write)
    {
      if (($dcc->{'flags'} & $DCC_TYPE) == $DCC_FILESEND)
	{
	  # We don't take much care about user acknowledgement
	  dcc_send_file($dcc);
	}
    }
  else
    {
      if ((    (($dcc->{'flags'} & $DCC_TYPE) == $DCC_FILESEND)
	    || (($dcc->{'flags'} & $DCC_TYPE) == $DCC_CHATSEND))
	  && ($dcc->{'flags'} & $DCC_QUEUED))
	{
	  dcc_i_accept($dcc);
	}
      else
	{
	  if (($dcc->{'flags'} & $DCC_TYPE) == $DCC_FILERECV)
	    {
	      dcc_recv_file($dcc);
	    }
	  elsif (($dcc->{'flags'} & $DCC_TYPE) == $DCC_FILESEND)
	    {
	      # Pity we have to wait for a user ack before sending out
	      dcc_recv_ack($dcc);
	    }
	  elsif (($dcc->{'flags'} & $DCC_TYPE) == $DCC_CHATRECV)
	    {
	      # MEMO: `send' flag must have already been dropped off
	      dcc_recv_chat($dcc);
	    }
	}
    }
  return 1;
}

#
# Channel management
#

our $UMODE_VOICE  = 0x01;
our $UMODE_CHOP	  = 0x02;

sub is_channel
{
  # This might not be enough
  return ($_[0] =~ /^[&#+!]/);
}

sub process_umode
{
  my $modes = shift;

  while ($modes =~ s/^\s*([+-])(\S+)//)
    {
      my $add = ($1 eq '+');

      foreach my $mode (split(//, $2))
	{
	  if ($add)
	    {
	      unless ($Current_Server->{'umode'} =~ /$mode/)
		{
		  $Current_Server->{'umode'} .= $mode;
		}
	    }
	  else
	    {
	      $Current_Server->{'umode'} =~ s/$mode//;
	    }
	}
    }

  irc_add_line('', "*: Your user modes: +%s", $Current_Server->{'umode'});
  VIM::DoCommand("call s:SetUserMode(\"$Current_Server->{'umode'}\")");
}

sub process_cmode
{
  my ($chan, $modes) = @_;

  if (0)
    {
      vim_printf("modes=%s", $modes);
    }

  if (my $cref = find_channel($chan))
    {
      if (my ($modes, $args) = ($modes =~ /^(\S+)(?:\s+(.+))?/))
	{
	  my ($add, $mode);
	  my @args = split(/\s+/, $args);

	  while ($mode = substr($modes, 0, 1))
	    {
	      if ($mode =~ /[-+]/)
		{
		  $add = ($mode eq '+');
		}
	      elsif ($mode =~ /[beIO]/)	# I just ignore these
		{
		  shift(@args);
		}
	      elsif ($mode =~ /[fJ]/) # dunno what these are for
		{
		  shift(@args);
		}
	      elsif ($mode eq 'k')
		{
		  if ($add)
		    {
		      $cref->{'key'} = shift(@args);
		    }
		  else
		    {
		      $cref->{'key'} = undef;
		    }
		}
	      elsif ($mode eq 'l')
		{
		  if ($add)
		    {
		      $cref->{'limit'} = shift(@args);
		    }
		  else
		    {
		      $cref->{'limit'} = 0;
		    }
		}
	      elsif ($mode =~ /[ov]/)
		{
		  my $nick = shift(@args);

		  if (my $nref = find_nick($nick, $chan))
		    {
		      my $val = $mode eq 'o' ? $UMODE_CHOP : $UMODE_VOICE;
		      if ($add)
			{
			  $nref->{'umode'} |= $val;
			  if (is_me($nick))
			    {
			      $cref->{'umode'} |= $val;
			    }
			}
		      else
			{
			  $nref->{'umode'} &= ~$val;
			  if (is_me($nick))
			    {
			      $cref->{'umode'} &= ~$val;
			    }
			}
		    }
		  draw_nickwin($chan);
		}
	      else
		{
		  if ($add)
		    {
		      if (index($cref->{'cmode'}, $mode) < 0)
			{
			  $cref->{'cmode'} .= $mode;
			}
		    }
		  else
		    {
		      $cref->{'cmode'} =~ s/$mode//;
		    }
		}
	      $modes = substr($modes, 1);
	    }
	}

	{
	  my $chan = do_escape($chan);
	  my $modes = $cref->{'cmode'};

	  if ($cref->{'key'} && $cref->{'limit'})
	    {
	      $modes .= "kl $cref->{'key'} $cref->{'limit'}";
	    }
	  elsif ($cref->{'key'})
	    {
	      $modes .= "k $cref->{'key'}";
	    }
	  elsif ($cref->{'limit'})
	    {
	      $modes .= "l $cref->{'limit'}";
	    }
	  VIM::DoCommand("call s:SetChannelMode(\"$chan\", \"$modes\")");
	}
    }
}

sub add_channel
{
  my ($chan, $key) = @_;
  my $cref;
  # We should not change cases here.  It may cause troubles with non-ascii
  # characters

  if (my $chans = $Current_Server->{'chans'})
    {
      unless (find_channel($chan))
	{
	  $cref = { name    => $chan,
		    key	    => $key,
		    limit   => 0,
		    info    => 0,
		    bufnum  => -1,
		    umode   => 0,
		    cmode   => undef,
		    nicks   => [],
		    splits  => []
		  };
	  push(@{$chans}, $cref);
	  $Current_Server->{'info'} |= $INFO_UPDATE;
	}
    }

  return $cref;
}

sub find_channel
{
  my ($chan, $sref) = @_;

  unless ($sref)
    {
      $sref = $Current_Server;
    }

  # XXX:  Here and there I'm assuming `foreach' is faster than `for'.
  #	  Correct me if it is wrong.
  foreach my $cref (@{$sref->{'chans'}})
    {
      if ($chan && lc($chan) ne lc($cref->{'name'}))
	{
	  next;
	}
      return $cref;
    }

  return undef;
}

sub del_channel
{
  my $chan  = lc($_[0]);

  if (my $chans = $Current_Server->{'chans'})
    {
      for (my $i = 0; $i <= $#{$chans}; $i++)
	{
	  if ($chan eq lc($chans->[$i]->{'name'}))
	    {
	      splice(@{$chans}, $i, 1);
	      $Current_Server->{'info'} |= $INFO_UPDATE;
	      last;
	    }
	}
      vim_close_channel($chan);
    }
}

#
# User management
#

sub is_me
{
  return ($_[0] eq $Current_Server->{'nick'});
}

sub get_nicks
{
  if (my $cref = find_channel($_[0]))
    {
      return $cref->{'nicks'};
    }
  return undef;
}

sub init_nicks
{
  if (my $nicks = get_nicks($_[0]))
    {
      @{$nicks} = ();
    }
}

sub sort_nicks
{
  if (my $nicks = get_nicks($_[0]))
    {
      @{$nicks} = sort { $b->{'umode'} <=> $a->{'umode'} }
		  sort { lc($a->{'nick'}) cmp lc($b->{'nick'}) }
		  @{$nicks};
    }
}

# Move designated nick on top of a list, making it easier to get prefix ([@+])
# for active speakers
sub refresh_nicks
{
  my ($nick, $chan) = @_;

  if (my $nicks = get_nicks($chan))
    {
      for (my $i = 0; $i <= $#{$nicks}; $i++)
	{
	  if ($nicks->[$i]->{'nick'} eq $nick)
	    {
	      my $nref = $nicks->[$i];

	      if ($i)
		{
		  splice(@{$nicks}, $i, 1);
		  unshift(@{$nicks}, $nref);
		  return 1;
		}
	      last;
	    }
	}
    }
  return 0;
}

sub add_nick
{
  my ($nick, $mode, $chan, $force) = @_;

  if (my $cref = find_channel($chan))
    {
      if (is_me($nick))
	{
	  $cref->{'umode'} = $mode;
	}

      if ($force || !find_nick($nick, $chan))
	{
	  unshift(@{$cref->{'nicks'}}, { nick => $nick, umode => $mode });
	}
    }
}

sub find_nick
{
  my ($nick, $chan) = @_;

  if (my $nicks = get_nicks($chan))
    {
      foreach my $nref (@{$nicks})
	{
	  if ($nref->{'nick'} eq $nick)
	    {
	      return $nref;
	    }
	}
    }
  return undef;
}

sub del_nick
{
  my ($nick, $chan) = @_;

  if (my $nicks = get_nicks($chan))
    {
      for (my $i = 0; $i <= $#{$nicks}; $i++)
	{
	  if ($nicks->[$i]->{'nick'} eq $nick)
	    {
	      splice(@{$nicks}, $i, 1);
	      return 1;
	    }
	}
    }
  return 0;
}

sub change_nick
{
  my ($old, $new, $chan) = @_;

  if (my $nref = find_nick($old, $chan))
    {
      $nref->{'nick'} = $new;
      return 1;
    }
  return 0;
}

sub find_nickprefix
{
  my ($nick, $chan) = @_;

  if (is_me($nick))
    {
      if (my $cref = find_channel($chan))
	{
	  return get_nickprefix($cref->{'umode'});
	}
    }
  else
    {
      if (my $nref = find_nick($nick, $chan))
	{
	  return get_nickprefix($nref->{'umode'});
	}
    }
  return undef;
}

sub get_nickprefix
{
  if (my $mode = $_[0])
    {
      my $pref = '';

      if ($mode & $UMODE_CHOP)
	{
	  $pref .= '@';
	}
      if ($mode & $UMODE_VOICE)
	{
	  $pref .= '+';
	}
      return $pref;
    }
  return undef;
}

sub draw_nickline
{
  my ($nick, $pref, $chan, $add) = @_;
  my $orgwin = VIM::Eval('winnr()');

  if (vim_visit_nicks($chan))
    {
      my $orglin= ($orgwin == VIM::Eval('winnr()')) ? VIM::Eval("getline('.')")
						    : undef;
      my $todel = vim_search("$pref$nick");

      unless ($add && $todel == 1)
	{
	  vim_bufmodify(1);
	  if ($todel)
	    {
	      $curbuf->Delete($todel);
	    }
	  if ($add)
	    {
	      $curbuf->Append(0, sprintf("%s%s", $pref, $nick));
	    }
	  vim_bufmodify(0);
	}
      if ($orglin)  # Restore the cursor position
	{
	  vim_search($orglin);
	}
      else
	{
	  # Keep top lines visible.  Since I dislike modifying the jumplist,
	  # I just set the cursor position here.
	  $curwin->Cursor(1, 0);  # but this doesn't update the view itself
	  VIM::DoCommand('normal! 0');	# so this is necessary
	}
      VIM::DoCommand("$orgwin wincmd w");
    }
  else
    {
      draw_nickwin($chan);
    }
}

sub draw_nickwin
{
  my $chan = shift;
  # Use bufnum since window number can change
  my $orgbuf = VIM::Eval("bufnr('%')");
  my $orgwin = VIM::Eval('winnr()');

  if (vim_open_nicks($chan))
    {
      my $nicks = get_nicks($chan);
      my $orglin= ($orgwin == VIM::Eval('winnr()')) ? VIM::Eval("line('.')")
						    : 0;

      vim_bufmodify(1);
      $curbuf->Delete(1, $curbuf->Count());

      foreach my $nref (@{$nicks})
	{
	  $curbuf->Append($curbuf->Count(), sprintf("%s%s",
					      get_nickprefix($nref->{'umode'}),
					      $nref->{'nick'}));
	}
      $curbuf->Delete(1);
      vim_bufmodify(0);

      if ($orglin)
	{
	  $curwin->Cursor($orglin, 0);
	}
      else
	{
	  VIM::DoCommand('normal! 0');
	}
      vim_selectwin($orgbuf);
    }
  else
    {
      if (my $cref = find_channel($chan))
	{
	  unless ($cref->{'info'} & $INFO_UPDATE)
	    {
	      $cref->{'info'} |= $INFO_UPDATE;
	    }
	}
    }
}

sub identify_nick
{
  # There might be a generalized way...
  my ($from, $mesg) = @_;
  my $nick = $Current_Server->{'nick'};
  our %NickServ;

  unless (defined(%NickServ))
    {
      $NickServ{'irc.freenode.net'} =
	{ nickserv  => 'NickServ',
	  regex	    => qr(type /msg NickServ \x02IDENTIFY\x02),
	  keyword   => 'IDENTIFY',
	};
    }

  if (my $nickserv = $NickServ{$Current_Server->{'server'}})
    {
      if ($from eq $nickserv->{'nickserv'} && ${$mesg} =~ $nickserv->{'regex'})
	{
	  unless (my $pass = $nickserv->{$nick})
	    {
	      my ($nickpass) = (vim_getvar('g:vimirc_nickpass')
				    =~ /([^,]+)\@$Current_Server->{'server'}/);
	      ($pass) = ($nickpass =~ /(?:^|\|)$nick:([^|]+)/);

	      unless ($pass)
		{
		  $pass = $nickpass;
		  unless ($pass)
		    {
		      $pass = VIM::Eval("s:InputS('Enter the nick password')");
		    }
		}
	      if ($pass)
		{
		  $nickserv->{$nick} = $pass;
		}
	    }
	  if ($nickserv->{$nick})
	    {
	      irc_add_line('', "*: Identifying yourself...");
	      irc_send("PRIVMSG %s :%s %s",
			$nickserv->{'nickserv'},
			$nickserv->{'keyword'},
			$nickserv->{$nick});
	      return 1;
	    }
	}
    }
  return 0;
}

sub add_chat
{
  my ($nick, $sref) = @_;
  my $chat;

  if (my $chats = $sref->{'chats'})
    {
      $chat = { nick  => $nick,
		info  => 0,
		bufnum=> -1
	      };
      push(@{$chats}, $chat);
      $sref->{'info'} |= $INFO_UPDATE;
    }

  return $chat;
}

sub find_chat
{
  my ($nick, $sref) = @_;

  foreach my $chat (@{$sref->{'chats'}})
    {
      if ($chat->{'nick'} eq $nick)
	{
	  return $chat;
	}
    }

  return undef;
}

sub del_chat
{
  my ($nick, $sref) = @_;

  if (my $chats = $sref->{'chats'})
    {
      for (my $i = 0; $i <= $#{$chats}; $i++)
	{
	  if ($chats->[$i]->{'nick'} eq $nick)
	    {
	      splice(@{$chats}, $i, 1);
	      $sref->{'info'} |= $INFO_UPDATE;
	      last;
	    }
	}
    }
}

sub find_chanserv
{
  my ($serv, $chan) = @_;
  my ($sref, $cref);

  if ($sref = find_server($serv))
    {
      $cref = $chan ? &{'find_cha'.(is_channel($chan)
				    ? 'nnel' : 't')}($chan, $sref)
		    : $sref;
    }

  return ($sref, $cref);
}

#
# Netsplit
#

sub add_netsplit
{
  my ($chan, $split) = @_;
  my $ns;

  if (my $cref = find_channel($chan))
    {
      $ns = { split => $split,
	      joins => 0,
	      nicks => {}   };
      push(@{$cref->{'splits'}}, $ns);
    }

  return $ns;
}

sub find_netsplit
{
  my ($nick, $chan, $split) = @_;

  foreach my $cref (@{$Current_Server->{'chans'}})
    {
      unless ($chan && $cref->{'name'} ne $chan)
	{
	  foreach my $ns (@{$cref->{'splits'}})
	    {
	      if ($split && $ns->{'split'} ne $split)
		{
		  next;
		}
	      if ($nick && !exists($ns->{'nicks'}->{$nick}))
		{
		  next;
		}
	      return $ns;
	    }
	  if ($chan)
	    {
	      last;
	    }
	}
    }

  return undef;
}

sub del_netsplit
{
  my ($chan, $split) = @_;

  if (my $cref = find_channel($chan))
    {
      my $splits = $cref->{'splits'};

      for (my $i = 0; $i <= $#{$splits}; $i++)
	{
	  if ($splits->[$i]->{'split'} eq $split)
	    {
	      splice(@{$splits}, $i, 1);
	      draw_nickwin($chan);
	      last;
	    }
	}
    }
}

sub add_splitnick
{
  my ($nick, $chan, $split) = @_;
  my $ns = find_netsplit(undef, $chan, $split);

  unless ($ns)
    {
      if ($ns = add_netsplit($chan, $split))
	{
	  # Forget about the leftovers?
	  add_timer(600, \&del_netsplit, [ $chan, $split ]);

	  unless (find_netsplit($nick, undef, $split))
	    {
	      irc_add_line('', "!: Netsplit detected: %s", $split);
	    }
	}
    }

  if ($ns)
    {
      $ns->{'nicks'}->{$nick} = 1;
    }
}

sub del_splitnick
{
  my ($nick, $chan) = @_;

  if (my $ns = find_netsplit($nick, $chan))
    {
      my $split = $ns->{'split'};

      unless ($ns->{'joins'}++)
	{
	  my $tojoin = scalar(keys(%{$ns->{'nicks'}}));
	  irc_add_line('', "*: Netjoin detected: %s, %d %s to join",
			    $split, $tojoin, ($tojoin > 1 ? 'are' : 'is'));
	}

      delete($ns->{'nicks'}->{$nick});
      unless (%{$ns->{'nicks'}})
	{
	  del_netsplit($chan, $split);
	  irc_add_line('', "*: Netsplit is over: %s", $split);
	}
      return 1;
    }
  return 0;
}

#
# Parsing IRC messages
#

sub parse_number
{
  my ($from, $comd, $args) = @_;
  my ($to, $mesg) = (${$args} =~ /^(\S+) :?(.*)$/);

  if (0)
    {
      vim_printf("from=%s comd=%s args=\"%s\"", $from, $comd, ${$args});
    }

  if ($comd == 001)	# RPL_WELCOME
    {
      set_connected(1);
      irc_add_line('', $mesg);
    }
  elsif ($comd == 002)	# RPL_YOURHOST
    {
      irc_add_line('', $mesg);
    }
  elsif ($comd == 003)	# RPL_CREATED
    {
      irc_add_line('', $mesg);
    }
  elsif ($comd == 004)	# RPL_MYINFO
    {
      irc_add_line('', $mesg);
    }
  elsif ($comd == 005)	# RPL_BOUNCE
    {
      # Most servers do not seem to use this code as what RFC suggests:
      # instead, they use it to indicate what options they have set, e.g., the
      # maximum length of nick
      # TODO: Make use of those options?
      irc_add_line('', $mesg);
    }
  elsif ($comd == 221)	# RPL_UMODEIS
    {
      if ($mesg =~ /^\+(\S*)/)
	{
	  irc_add_line('', "*: Your user modes: +%s", $1);
	  VIM::DoCommand("call s:SetUserMode(\"$1\")");
	}
    }
  elsif ($comd >= 250 && $comd <= 259)  # RPL_LUSERCLIENT etc.
    {
      irc_add_line('', $mesg);
    }
  elsif ($comd == 265 || $comd == 266)
    {
      irc_add_line('', $mesg);
    }
  elsif ($comd == 301)	# RPL_AWAY
    {
      if (my ($nick, $mesg) = ($mesg =~ /^(\S+)\s+:(.*)$/))
	{
	  irc_add_line('', "%s is away: %s", $nick, $mesg);
	}
    }
  elsif ($comd == 302)	# RPL_USERHOST
    {
      # Get the first one.  This should be called upon logon, to obtain your
      # hostname.  Necessary for dcc things.
      if (my ($nick, $host) = ($mesg =~ /^([^*=+-]+)[^@]+@(\S+)/))
	{
	  if (is_me($nick))
	    {
	      $Current_Server->{'local'} = $host;
	      irc_add_line('', "*: Your local host: %s", $host);
	    }
	  else
	    {
	      irc_add_line('', "USERHOST: %s", $mesg);
	    }
	}
    }
  elsif ($comd == 303)	# RPL_ISON
    {
      irc_add_line('', "ISON: %s", $mesg);
    }
  elsif ($comd == 305 || $comd == 306)	# RPL_UNAWAY/RPL_NOWAWAY
    {
      irc_add_line('', $mesg);
    }
  elsif ($comd == 311 || $comd == 314)	# RPL_WHOISUSER
    {
      if (my ($nick, $user, $host, $info) =
				  ($mesg =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(.+)$/))
	{
	  irc_add_line('', "%s %ss %s@%s %s",
			  $nick,
			  ($comd == 311 ? "i" : "wa"),
			  $user,
			  $host,
			  $info);
	}
    }
  elsif ($comd == 312)	# RPL_WHOISSERVER
    {
      if (my ($nick, $server) = ($mesg =~ /^(\S+)\s+(.+)$/))
	{
	  irc_add_line('', "%s using %s", $nick, $server);
	}
    }
  elsif ($comd == 315)	# RPL_ENDOFWHO
    {
      irc_add_line('', $mesg);
    }
  elsif ($comd == 317)	# RPL_WHOISIDLE
    {
      if (my ($nick, $idle, $signon) = ($mesg =~ /^(\S+)\s+(\d+)(?:\s+(\d+))?/))
	{
	  $idle = sprintf("%02d:%02d:%02d",
			  ($idle / 3600),
			  (($idle % 3600) / 60),
			  ($idle % 60));
	  irc_add_line('', "%s has been idle for %s%s",
			  $nick,
			  $idle,
			  ($signon
			    ? ', signed on '.vim_gettime(0, $signon)
			    : ''));
	}
    }
  elsif ($comd == 318 || $comd == 369)	# RPL_ENDOFWHOIS
    {
      if (my ($nick, $mesg) = ($mesg =~ /^(\S+)\s+:?(.+)$/))
	{
	  irc_add_line('', "%s %s", $nick, $mesg);
	}
    }
  elsif ($comd == 319)	# RPL_WHOISCHANNELS
    {
      if (my ($nick, $chan) = ($mesg =~ /^(\S+)\s+:?(.+)$/))
	{
	  irc_add_line('', "%s on %s", $nick, $chan);
	}
    }
  elsif ($comd == 320)	# I see "is an identified user" on dancer-ircd
    {
      if (my ($nick, $mesg) = ($mesg =~ /^(\S+)\s+:?(.+)$/))
	{
	  irc_add_line('', "%s %s", $nick, $mesg);
	}
    }
  elsif ($comd == 321)	# RPL_LISTSTART
    {
      irc_add_line('', '*: Listing channels...');
    }
  elsif ($comd == 322)	# RPL_LIST
    {
      if (my ($chan, $num, $topic) = ($mesg =~ /^(\S+)\s+(\d+)\s+:(.*)$/))
	{
	  unless (VIM::Eval('s:VisitBuf_List()'))
	    {
	      VIM::DoCommand('split|call s:OpenBuf_List()');
	    }
	  $curbuf->Append($curbuf->Count(), sprintf("%-22s %5d %s",
						    $chan, $num, $topic));
	}
    }
  elsif ($comd == 323)	# RPL_LISTEND
    {
      if (VIM::Eval('s:VisitBuf_List()'))
	{
	  VIM::DoCommand('call s:BufTrim()');
	  VIM::DoCommand('call s:HiliteLine(".")');
	  irc_add_line('', $mesg);
	}
    }
  elsif ($comd == 324)	# RPL_CHANNELMODEIS
    {
      if (my ($chan, $modes) = ($mesg =~ /^(\S+)\s+:?(.+)$/))
	{
	  process_cmode($chan, $modes);
	}
    }
  elsif ($comd == 329)
    {
      if (my ($chan, $time) = ($mesg =~ /^(\S+)\s+(\d+)$/))
	{
	  irc_add_line($chan, "*: %s came into existence on %s", $chan,
							vim_gettime(0, $time));
	}
    }
  elsif ($comd == 331)	# RPL_NOTOPIC
    {
      if (my ($chan, $mesg) = ($mesg =~ /^(\S+)\s+:?(.*)$/))
	{
	  irc_add_line($chan, "*: %s", $mesg);
	}
    }
  elsif ($comd == 332)	# RPL_TOPIC
    {
      if (my ($chan, $topic) = ($mesg =~ /^(\S+)\s+:(.*)$/))
	{
	  irc_add_line($chan, "*: Topic for %s:", $chan);
	  irc_add_line($chan, "*: %s", $topic);

	  if (find_channel($chan))
	    {
	      $chan = do_escape($chan);
	      $topic= do_escape($topic);
	      VIM::DoCommand("call s:SetChannelTopic(\"$chan\", \"$topic\")");
	    }
	}
    }
  elsif ($comd == 333)
    {
      if (my ($chan, $nick, $time) = ($mesg =~ /^(\S+)\s+(\S+)\s+(\d+)$/))
	{
	  irc_add_line($chan, "*: Topic set by %s at %s", $nick,
							vim_gettime(0, $time));
	}
    }
  elsif ($comd == 341)	# RPL_INVITING
    {
      if (my ($nick, $chan) = ($mesg =~ /^(\S+)\s+(\S+)$/))
	{
	  irc_add_line('', "*: %s has been invited to %s", $nick, $chan);
	}
    }
  elsif ($comd == 352)	# RPL_WHOREPLY
    {
      # Discarding the hopcount
      my ($chan, $user, $host, $server, $nick, $flag, undef, $real) =
		($mesg =~ /^(\S+) (\S+) (\S+) (\S+) (\S+) (\S+) :(\d+) (.+)$/);
      irc_add_line('', "%-16s %-12s %-3s %s@%s (%s)",
			$chan, $nick, $flag, $user, $host, $real);
    }
  elsif ($comd == 353)	# RPL_NAMREPLY
    {
      my ($type, $chan, $nicks) = ($mesg =~ /^(.)\s+(\S+)\s+:(.+)$/);

      if (find_channel($chan))
	{
	  foreach my $nick (split(/\s+/, $nicks))
	    {
	      my $mode = 0;
	      if ($nick =~ s/^@//)
		{
		  $mode |= $UMODE_CHOP;
		}
	      if ($nick =~ s/^\+//)
		{
		  $mode |= $UMODE_VOICE;
		}
	      add_nick($nick, $mode, $chan, 1);
	    }
	}
      else
	{
	  irc_add_line('', "*: Names for %s: %s", $chan, $nicks);
	}
    }
  elsif ($comd == 366)	# RPL_ENDOFNAMES
    {
      if (my ($chan) = ($mesg =~ /^(\S+)/))
	{
	  if (find_channel($chan))
	    {
	      sort_nicks($chan);
	      draw_nickwin($chan);
	    }
	  else
	    {
	      irc_add_line('', "*: End of names");
	    }
	}
    }
  elsif ($comd == 372 || $comd == 375)	# RPL_MOTD/RPL_MOTDSTART
    {
      unless ($Current_Server->{'conn'} & $CS_RECON)
	{
	  irc_add_line('', $mesg);
	}
    }
  elsif ($comd == 376)	# RPL_ENDOFMOTD
    {
      unless ($Current_Server->{'conn'} & $CS_RECON)
	{
	  irc_add_line('', $mesg);
	}
      unless ($Current_Server->{'motd'})
	{
	  post_login_server($Current_Server);
	}
    }
  elsif ($comd == 391)	# RPL_TIME
    {
      irc_add_line('', $mesg);
    }
  elsif ($comd >= 431 && $comd <= 433)	# ERR_NICKNAMEINUSE etc.
    {
      irc_add_line('', $mesg);
      unless ($Current_Server->{'conn'} & $CS_LOGIN)
	{
	  $Current_Server->{'nick'} .= '_';
	  irc_send("NICK %s", $Current_Server->{'nick'});
	}
    }
  elsif ($comd == 471 || $comd == 475)	# ERR_BADCHANNELKEY
    {
      if (my ($chan) = ($mesg =~ /^(\S+)/))
	{
	  del_channel($chan);
	  irc_add_line('', "!: %s", $mesg);
	}
    }
  else
    {
      irc_add_line('', "%s: %s", $comd, $mesg);
    }
}

sub parse_invite
{
  my ($from, $args) = @_;

  if (my ($chan) = (${$args} =~ /^\S+\s+:?(\S+)$/))
    {
      irc_add_line('', "!: %s invites you to channel %s", $from, $chan);
      # Ask user to join
      vim_beep(2);

      if (vim_getconf("$from invites you to join $chan. Accept it?"))
	{
	  VIM::DoCommand('call s:Send_JOIN("JOIN", "'.do_escape($chan).'")');
	}
    }
}

sub parse_join
{
  my ($from, $args) = @_;

  if (my ($chan) = (${$args} =~ /^:?(\S+)/))
    {
      add_nick($from, 0, $chan);

      unless (del_splitnick($from, $chan))
	{
	  # If it is you who is entering, get the channel mode.
	  if (is_me($from))
	    {
	      # Keep your name from appearing twice in the nicks window,
	      # assuming NAMES are sent just after the JOIN line.  I.e.,
	      # assuming the internal nicks list contains your name only at
	      # this point in time.  I'm doing this because I don't want to
	      # check duplicates in add_nick(), for speed issue.
	      init_nicks($chan);
	      irc_send("MODE %s", $chan);
	    }
	  else
	    {
	      draw_nickline($from, undef, $chan, 1);
	    }
	  irc_add_line($chan, "->: Enter %s [%s]", $from, $From_Server);
	}
    }
}

sub parse_kick
{
  my ($from, $args) = @_;

  if (my ($chan, $nick, $mesg) = (${$args} =~ /^(\S+)\s+(\S+)\s+:(.*)$/))
    {
      my $pref = find_nickprefix($nick, $chan);

      del_nick($nick, $chan);

      if (is_me($nick))
	{
	  irc_add_line('', "!: You have been kicked off channel %s by %s (%s)",
			    $chan, $from, $mesg);
	  del_channel($chan);
	}
      else
	{
	  draw_nickline($nick, $pref, $chan, 0);
	  irc_add_line($chan, "!: %s kicks off %s (%s)", $from, $nick, $mesg);
	}
    }
}

sub parse_mode
{
  my ($from, $args) = @_;

  if (my ($chan, $modes) = (${$args} =~ /^(\S+)\s+:?(.+)$/))
    {
      if (is_channel($chan))
	{
	  process_cmode($chan, $modes);
	  irc_add_line($chan, "*: %s sets new mode: %s", $from, $modes);

	}
      elsif (is_me($chan))
	{
	  process_umode($modes);
	}
    }
}

sub parse_nick
{
  my ($from, $args) = @_;

  if (my ($nick) = (${$args} =~ /^:(.+)$/))
    {
      if (is_me($from))
	{
	  $Current_Server->{'nick'} = $nick;
	  irc_add_line('', "*: New nick %s approved", $nick);
	  irc_send("MODE %s", $nick);
	}

      foreach my $cref (@{$Current_Server->{'chans'}})
	{
	  my $chan = $cref->{'name'};
	  if (change_nick($from, $nick, $chan))
	    {
	      draw_nickwin($chan);
	      irc_add_line($chan, "*: %s is now known as %s", $from, $nick);
	    }
	}
      dcc_change_nick($from, $nick);
    }
}

sub parse_notice
{
  my ($from, $args) = @_;

  if (my ($chan, $mesg) = (${$args} =~ /^(\S+)\s+:?(.*)$/))
    {
      unless (identify_nick($from, \$mesg)) # if not from nickserv
	{
	  if (process_ctcp_reply($from, $chan, \$mesg))
	    {
	      irc_add_line($chan, "[%s%s]: %s",
				  (is_channel($chan)
				    ? find_nickprefix($from, $chan) : undef),
				  $from, $mesg);
	      unless (is_channel($chan))
		{
		  vim_beep(1);
		}
	    }
	}
    }
}

sub parse_part
{
  my ($from, $args) = @_;
  my ($chan, $mesg) = (${$args} =~ /^(\S+)\s+:(.*)$/);
  my $pref = find_nickprefix($from, $chan);

  if (del_nick($from, $chan))
    {
      if (is_me($from))
	{
	  del_channel($chan);
	}
      else
	{
	  draw_nickline($from, $pref, $chan, 0);
	  irc_add_line($chan, "<-: Exit %s%s [%s] (%s)", $pref, $from,
							  $From_Server, $mesg);
	}
    }
}

sub parse_ping
{
  my $args = shift;

  $Current_Server->{'lastping'} = time();
  irc_send("PONG :%s", ${$args});

  if (0)
    {
      irc_add_line('', "Ping? Pong!");
    }
}

sub parse_pong
{
  my ($from, $args) = @_;

  if (0 && (my ($time) = (${$args} =~ /(\d+)$/)))
    {
      my $diff = time() - $time;
      irc_add_line('', "*: Pong from %s (%d second%s)", $from, $diff,
						      ($diff != 1 ? 's' : ''));
    }
}

sub parse_privmsg
{
  my ($from, $args) = @_;

  if (my ($chan, $mesg) = (${$args} =~ /^(\S+)\s+:(.*)$/))
    {
      my $pref;

      if (is_channel($chan))
	{
	  $pref = find_nickprefix($from, $chan);

	  if (refresh_nicks($from, $chan))
	    {
	      draw_nickline($from, $pref, $chan, 1);
	    }
	}

      # Handle CTCP messages first
      if (process_ctcp_query($from, $pref, $chan, \$mesg))
	{
	  if (is_channel($chan))
	    {
	      irc_add_line($chan, "<%s%s>: %s", $pref, $from, $mesg);
	    }
	  elsif (is_me($chan))
	    {
	      irc_chat_line($from, "<%s>: %s", $from, $mesg);
	      unless ($Current_Server->{'away'})
		{
		  vim_beep(1);
		}
	    }
	}
    }
}

sub parse_quit
{
  my ($from, $args) = @_;
  my ($mesg)= (${$args} =~ /^:(.+)$/);
  my $regex = qr([[:alnum:]]+(?:\.[-[:alnum:]]+)+);
  my $split = ($mesg =~ /^$regex $regex$/);

  foreach my $cref (@{$Current_Server->{'chans'}})
    {
      my $chan = $cref->{'name'};
      my $pref = find_nickprefix($from, $chan);

      if (del_nick($from, $chan))
	{
	  # Handle netsplits: just hide QUIT messages if one occurs.  Also,
	  # hold the nicks, who are to be resurrected, to hide the expected
	  # JOIN messages.
	  if ($split)
	    {
	      add_splitnick($from, $chan, $mesg);
	    }
	  else
	    {
	      draw_nickline($from, $pref, $chan, 0);
	      irc_add_line($chan, "<=: Exit %s%s [%s] (%s)", $pref, $from,
							  $From_Server, $mesg);
	    }
	}
    }
}

sub parse_topic
{
  my ($from, $args) = @_;

  if (my ($chan, $topic) = (${$args} =~ /^(\S+)\s+:(.*)$/))
    {
      irc_add_line($chan, "*: %s sets new topic: %s", $from, $topic);

	{
	  my $chan = do_escape($chan);
	  my $topic= do_escape($topic);
	  VIM::DoCommand("call s:SetChannelTopic(\"$chan\", \"$topic\")");
	}
    }
}

sub parse_wallops
{
  my ($from, $args) = @_;

  if (my ($mesg) = (${$args} =~ /^:(.+)$/))
    {
      irc_add_line('', "!%s!: %s", $from, $mesg);
    }
}

sub parse_line
{
  my $line = shift;

  if (my ($from, $comd, $args) = (${$line} =~ /^:(\S+)\s+(\S+)\s+(.*)$/))
    {
      ($from, $From_Server) = ($from =~ /^([^!]+)(?:!(\S+))?$/);

      if (0)
	{
	  vim_printf("from=%s server=%s comd=%s args=%s", $from, $From_Server,
								$comd, $args);
	}

      if ($comd + 0)
	{
	  parse_number($from, $comd, \$args);
	}
      else
	{
	  $comd = lc($comd);

	  if (defined(&{'parse_'.$comd}))
	    {
	      &{'parse_'.$comd}($from, \$args);
	    }
	  else
	    {
	      irc_add_line('', "%s", ${$line});
	    }
	}
    }
  else
    {
      if (($comd, $args) = (${$line} =~ /^(\S+)\s+:?(.*)$/))
	{
	  if (0)
	    {
	      vim_printf("comd=%s args=%s", $comd, $args);
	    }
	  $comd = lc($comd);

	  if ($comd eq 'notice')
	    {
	      irc_add_line('', "%s", $args);
	    }
	  elsif ($comd && defined(&{'parse_'.$comd}))
	    {
	      &{'parse_'.$comd}(\$args);
	    }
	  else
	    {
	      irc_add_line('', "%s", ${$line});
	    }
	}
    }
}

#
# Misc. utility functions
#

# When passing string to vim, '"' and '\' must be escaped
sub do_escape
{
  my $str = shift;

  $str =~ s/(["\\])/\\$1/g;
  return $str;
}

sub do_urldecode
{
  my $str = shift;

  $str =~ s/%([[:xdigit:]]{2})/pack('C', hex($1))/eg;
  return $str;
}

sub do_urlencode
{
  my $str = shift;

  $str =~ s/([`'!@#\$%^&*(){}<>~|\\\";? ,\/])/'%'.unpack('H2', $1)/eg;
  return $str;
}

# Implements `mkdir -p'
sub my_mkdir
{
  my $dir = shift;
  # Dunno why perl doesn't have `pwd'.  Or does it?
  my $cwd = VIM::Eval('getcwd()');

  unless (-d $dir)
    {
      my $tmp = $dir;
      while ($tmp =~ s#^(.+?/)##)
	{
	  unless (chdir($1) || (mkdir($1) && chdir($1)))
	    {
	      last;
	    }
	}
      unless (-d $dir)	# final check
	{
	  mkdir($dir);
	}
    }

  VIM::DoCommand("cd $cwd");
  return (-d $dir) + 0;
}

sub vim_getvar
{
  my $var = shift;

  return VIM::Eval("exists('$var')") ? scalar(VIM::Eval("$var")) : undef;
}

sub vim_printf
{
  VIM::Msg(sprintf(shift(@_), @_));
}

sub vim_getconf
{
  return scalar(VIM::Eval('s:GetConf_YN("'.do_escape($_[0]).'")'));
}

sub vim_beep
{
  VIM::DoCommand("call s:Beep($_[0])");
}

sub vim_search
{
  return scalar(VIM::Eval('s:SearchLine("'.do_escape($_[0]).'")'));
}

sub vim_gettime
{
  # I think Vim's strftime is much faster than perl's equivalent
  return scalar(VIM::Eval("s:GetTime($_[0], $_[1])"));
}

sub vim_open_server
{
  VIM::DoCommand('call s:OpenBuf_Server()');
}

sub vim_visit_server
{
  scalar(VIM::Eval('s:VisitBuf_Server()'));
}

sub vim_open_channel
{
  return scalar(VIM::Eval('s:OpenBuf_Channel("'.do_escape($_[0]).'")'));
}

sub vim_visit_channel
{
  return scalar(VIM::Eval('s:VisitBuf_Channel("'.do_escape($_[0]).'")'));
}

sub vim_close_channel
{
  VIM::DoCommand('call s:CloseBuf_Channel("'.do_escape($_[0]).'")');
}

sub vim_open_nicks
{
  return scalar(VIM::Eval('s:OpenBuf_Nicks("'.do_escape($_[0]).'")'));
}

sub vim_visit_nicks
{
  return scalar(VIM::Eval('s:VisitBuf_Nicks("'.do_escape($_[0]).'")'));
}

sub vim_open_chat
{
  VIM::DoCommand('call s:OpenBuf_Chat("'.do_escape($_[0]).'", "'.$_[1].'")');
}

sub vim_visit_chat
{
  return scalar(VIM::Eval('s:VisitBuf_Chat("'.do_escape($_[0]).'", "'.$_[1].'")'));
}

sub vim_close_chat
{
  VIM::DoCommand('call s:CloseBuf_Chat("'.do_escape($_[0]).'", "'.$_[1].'")');
}

sub vim_open_info
{
  return scalar(VIM::Eval('s:OpenBuf_Info()'));
}

sub vim_selectwin
{
  return scalar(VIM::Eval("s:SelectWindow($_[0])"));
}

sub vim_bufmodify
{
  if ($_[0])
    {
      VIM::DoCommand('call s:PreBufModify()');
    }
  else
    {
      VIM::DoCommand('call s:PostBufModify()');
    }
}

sub vim_notifyentry
{
  VIM::DoCommand('call s:NotifyNewEntry()');
}

sub vim_redraw
{
  VIM::DoCommand('redraw');
}

sub vim_peekbuf
{
  if ($_[0])
    {
      VIM::DoCommand('call s:PrePeekBuf()');
    }
  else
    {
      VIM::DoCommand('call s:PostPeekBuf()');
    }
}

EOP
endfunction
if exists('s:sid') && s:debug
  call s:PerlIRC()
endif
endif

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions

" vim:ts=8:sts=2:sw=2:fdm=indent:
