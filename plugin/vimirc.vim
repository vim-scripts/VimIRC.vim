" An IRC client plugin for Vim
" Maintainer: Madoka Machitani <madokam@zag.att.ne.jp>
" Created: Tue, 24 February 2004
" Last Change: Mon, 22 Mar 2004 17:57:11 +0900 (JST)
" License: Distributed under the same terms as Vim itself
"
" Credits:
"   ircII		the basics of IRC
"   X-Chat		ideas for DCC implementation specifically
"   KoRoN		creator of a BBS viewer for Vim, Chalice (very popular
"			among Japanese vim community)
"   Ilya Sher		an idea for mini-buffers for cmdline editing
"
" Features:
"   * real-time message receiving with user interaction (many of the normal
"     mode commands available)
"   * multiple servers/channels connectivity
"   * DCC SEND/CHAT functionalities
"
"   A Drawback:
"     VimIRC achieves real-time message reception by implementing its own main
"     loop.  Therefore, while you are out of it, VimIRC has no way to get new
"     messages.  So my recommendation is, use a shortcut which creates
"     a VimIRC-dedicated instance of Vim, where you do not initiate normal
"     editing sessions.
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
"     let g:vimirc_umode	="user mode" set upon logon (e.g.: "+i")
"     let g:vimirc_server	="your favorite IRC server" in a format:
"				  irc.foobar.com:6667
"				  (default: irc.freenode.net)
"
"   Misc.:
"     let g:vimirc_partmsg	="message sent with QUIT/PART"
"     let g:vimirc_winmode	="single" is the only valid value
"				  (default: multi-windows mode)
"
"   DCC-related:
"     let g:vimirc_dccdir	="where files are downloaded"
"				  (default: ~/.vimirc/dcc)
"     let g:vimirc_dccport	=port-number to watch at when you set up
"				  a dcc server.  necessary to set if you are
"				  behind firewall or something.
"
"   Runtime Options:
"     You can pass following options to the command :VimIRC, overriding the
"     vim variables above
"
"	-n nickname
"	-u username
"	-s server:port
"
"	and
"
"	--realname="full name"
"
" Startup:
"   Type
"     :VimIRC<CR>
"
"   You will be prompted for several user information if you have not set
"   variables listed above.
"
" Usage:
"   Normal mode:  This is a pseudo normal mode.  Just try several normal-mode
"		  commands as usual.  Some are available, and some are not.
"
"		  Type "i" or "I" to enter the `command mode' described
"		  below, just as you do in vi to go insert mode.
"
"		  Type <Ctrl-C> to get out of control and freely move around
"		  or do ex commands.
"
"		  Hit <Space> to re-enter the normal (online) mode.
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
"     :VimIRCQuit<CR>
"   in the VIM command line.
"
" TODOs:
"   * multibyte support (done? I don't think so)
"   * logging
"   * authentication (just add one line to send PASS)
"   * auto reconnect/rejoin
"   * flood protection
"   * netsplit detection
"   * SSL
"   * IPv6
"   * scripting (?)
"   * ctcp, including dcc stuffs (mostly done)
"   * help
"   * etc. etc.
"
"   Done:
"   - command-line history (?)
"   - separate listing of channels with sorting facilities
"

if exists('g:loaded_vimirc') || &compatible
  finish
endif

let s:save_cpoptions = &cpoptions
set cpoptions&

let s:version = '0.6'
let s:client = 'VimIRC '.s:version
" Set this to zero when releasing, which I'll occasionally forget, for sure
let s:debug = 0

if !s:debug
  let g:loaded_vimirc = 1
endif

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
  if exists('s:bufname_prefix') " already inited
    return
  endif

  map <SID>xx <SID>xx
  let s:sid = substitute(maparg('<SID>xx'), 'xx$', '', '')
  unmap <SID>xx

  let s:bufname_prefix	= '_VimIRC_'
  let s:bufname_server	= s:bufname_prefix.'SERVER_'
  let s:bufname_list	= s:bufname_prefix.'LIST_'
  let s:bufname_channel = s:bufname_prefix.'CHANNEL_'
  let s:bufname_names	= s:bufname_prefix.'NAMES_'
  let s:bufname_command = s:bufname_prefix.'COMMAND_'
  let s:bufname_chat	= s:bufname_prefix.'DCCCHAT_'

  " User options below

  " Favorite farewell message
  let s:partmsg = s:GetVimVar('g:vimirc_partmsg')
  if !strlen(s:partmsg)
    let s:partmsg = (s:debug ? 'Testing ' : '').s:client.' (IRC client for Vim)'
  endif
  " Prepend a leading colon
  let s:partmsg = substitute(s:partmsg, '^[^:]', ':&', '')

  " Preferred language.  Encoding name which Perl's Encode module can accept
  let s:preflang = s:GetVimVar('g:vimirc_preflang')

  "
  let s:logdir = s:GetVimVar('g:vimirc_logdir')
  if !strlen(s:logdir)
    let s:logdir = expand('$HOME').'/.vimirc'
  endif
  let s:logdir = s:RegularizePath(s:logdir)

  " Directory where incoming dcc files should go
  let s:dccdir = s:GetVimVar('g:vimirc_dccdir')
  if !strlen(s:dccdir)
    let s:dccdir = s:logdir.'/dcc'
  endif
  let s:dccdir = s:RegularizePath(s:dccdir)

  " Preferred port you want to listen to
  let s:dccport = s:GetVimVar('g:vimirc_dccport')

  " Window mode
  " TODO: Toggling mechanism
  let s:singlewin = (s:GetVimVar('g:vimirc_winmode') ==? 'single')
endfunction

function! s:SetGlobVars()
  let s:eadirection = &eadirection
  set eadirection=ver
  let s:equalalways = &equalalways
  set equalalways
  let s:lazyredraw = &lazyredraw
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
    echoerr "To use this, you have to build vim with perl interface. Exiting."
    return
  endif

  if exists('s:opened') && s:opened
    return
  endif

  call s:InitVars()
  if !s:ObtainUserInfo(a:0 ? a:1 : '')
    return
  endif

  call s:SetGlobVars()
  call s:DoCommands()
  call s:DoAutocmds()

  call s:SetEncoding()
  call s:PerlIRC()

  call s:Server(s:server)
  let s:opened = 1

  call s:MainLoop()
endfunction

function! s:QuitVimIRC()
  call s:UndoCommands()
  call s:UndoAutocmds()
  call s:ResetGlobVars()
  call s:QuitServers()
  call s:CloseVimIRC()
  let s:opened = 0
endfunction

function! s:DoCommands()
  delcommand VimIRC
  command! VimIRCQuit :call s:QuitVimIRC()
endfunction

function! s:UndoCommands()
  delcommand VimIRCQuit
  command! -nargs=* VimIRC :call s:StartVimIRC()
endfunction

function! s:DoAutocmds()
  augroup VimIRC
    autocmd!
    " NOTE: Cannot use CursorHold to auto re-enter the loop: getchar() won't
    "	    get a char since key inputs will never be waited after that event.
    execute 'autocmd CursorHold' s:bufname_prefix.'* call s:OfflineMsg()'
  augroup END
endfunction

function! s:UndoAutocmds()
  augroup VimIRC
    autocmd! CursorHold
    "autocmd! BufHidden
  augroup END
endfunction

function! s:MainLoop()
  if !(exists('s:opened') && s:opened && s:IsSockOpen())
    return
  endif

  " Clearing the vim command line
  echo ""
  " TODO: What if already inside the loop?
  while 1
    try
      let key = getchar(0)
      if ''.key != '0'
	call s:HandleKey(key)
	continue
      endif
      if !s:RecvData()
	break
      endif
    catch /^IMGONNA/
      " Get out of the loop
      " NOTE: You cannot see new messages posted while posting
      if v:exception =~# 'POST$' && mode() !=# 'i'
	" FIXME: Sometimes "startinsert" in OpenBuf_Command doesn't seem to work
	startinsert
      endif
      break
    catch /^Vim:Interrupt$/
      match none
      if s:IsBufCommand()
	startinsert!
      endif
      break
    endtry
  endwhile
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

function! s:GetBufNum_Server()
  return s:GetBufNum(s:GenBufName_Server(s:server))
endfunction

function! s:GetBufNum_List()
  return s:GetBufNum(s:GenBufName_List(s:server))
endfunction

function! s:GetBufNum_Channel(channel)
  return s:GetBufNum(s:GenBufName_Channel(s:server, a:channel))
endfunction

function! s:GetBufNum_Names(channel)
  return s:GetBufNum(s:GenBufName_Names(s:server, a:channel))
endfunction

function! s:GetBufNum_Command(channel)
  return s:GetBufNum(s:GenBufName_Command(s:server, a:channel))
endfunction

function! s:GetBufNum_Chat(nick, server)
  return s:GetBufNum(s:GenBufName_Chat(a:nick, a:server))
endfunction

function! s:SetBufNum(bufname, bufnum)
  let s:bufnum_{a:bufname} = a:bufnum
endfunction

function! s:DeleteBufNum(bufnum)
  unlet! s:bufnum_{bufname(a:bufnum)}
endfunction

function! s:GenBufName_Server(server)
  return s:bufname_server.a:server
endfunction

function! s:GenBufName_List(server)
  return s:bufname_list.a:server
endfunction

function! s:GenBufName_Channel(server, channel)
  return s:bufname_channel.a:server.s:SecureChannel(a:channel)
endfunction

function! s:GenBufName_Names(server, channel)
  return s:bufname_names.a:server.s:SecureChannel(a:channel)
endfunction

function! s:GenBufName_Command(server, channel)
  return s:bufname_command.a:server.s:SecureChannel(a:channel)
endfunction

function! s:GenBufName_Chat(nick, server)
  return s:bufname_chat.a:server.s:SecureBufName('='.a:nick)
endfunction

function! s:SecureBufName(bufname)
  return escape(a:bufname, '#')
endfunction

function! s:SecureChannel(channel)
  return s:SecureBufName(tolower(a:channel))
endfunction

function! s:IsBufIRC(...)
  return !match(bufname(a:0 && a:1 ? a:1 : '%'), s:bufname_prefix)
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

function! s:IsBufNames()
  return !match(bufname(a:0 && a:1 ? a:1 : '%'), s:bufname_names)
endfunction

function! s:IsBufCommand(...)
  return !match(bufname(a:0 && a:1 ? a:1 : '%'), s:bufname_command)
endfunction

function! s:IsBufChat(...)
  return !match(bufname(a:0 && a:1 ? a:1 : '%'), s:bufname_chat)
endfunction

function! s:VisitServer()
  return (s:SelectWindow(s:GetBufNum_Server()) >= 0)
endfunction

function! s:VisitList()
  return (s:SelectWindow(s:GetBufNum_List()) >= 0)
endfunction

function! s:VisitChannel(chan)
  return (s:SelectWindow(s:GetBufNum_Channel(a:chan)) >= 0)
endfunction

"
" Opening buffers
"

function! s:OpenBuf(comd, buffer)
  " Avoid "not enough room" error
  let winminheight  = &winminheight
  let winminwidth   = &winminwidth
  set winminheight=0
  set winminwidth=0
  silent execute a:comd a:buffer
  let &winminheight = winminheight
  let &winminwidth  = winminwidth
endfunction

function! s:OpenBuf_Server()
  let bufnum = s:GetBufNum_Server()
  if bufnum >= 0
    if s:SelectWindow(bufnum) < 0
      call s:OpenBuf('split', '+'.bufnum.'buffer')
    endif
  else
    let bufname = s:GenBufName_Server(s:server)
    call s:OpenBuf((s:GetVimVar('s:opened') ? 'split' : 'edit!'), bufname)
    call s:InitBuf_Server(bufname)
  endif

  unlet! b:dead
  silent! wincmd J
endfunction

function! s:OpenBuf_List()
  let bufnum = s:GetBufNum_List()
  " Open it next to the server window
  call s:SelectWindow(s:GetBufNum_Server())
  if bufnum >= 0
    if s:SelectWindow(bufnum) < 0
      call s:OpenBuf('vertical split', '+'.bufnum.'buffer')
    endif
  else
    let bufname = s:GenBufName_List(s:server)
    call s:OpenBuf('vertical split', bufname)
    call s:InitBuf_List(bufname)
  endif
endfunction

function! s:OpenBuf_Channel(channel)
  if s:singlewin
    return
  endif

  let bufnum  = s:GetBufNum_Channel(a:channel)
  " TODO: Height should be configurable
  let comd = 'botright split'
  if bufnum >= 0
    if s:SelectWindow(bufnum) < 0
      call s:OpenBuf(comd, '+'.bufnum.'buffer')
    endif
  else
    let bufname = s:GenBufName_Channel(s:server, a:channel)
    call s:OpenBuf(comd, bufname)
    call s:InitBuf_Channel(bufname, a:channel)
  endif
  if &l:winfixheight
    let &l:winfixheight = !&l:winfixheight
  endif
endfunction

function! s:OpenBuf_Names(channel)
  let bufnum  = s:GetBufNum_Names(a:channel)
  let comd = 'vertical belowright 12split'
  call s:VisitChannel(a:channel)
  if bufnum >= 0
    if s:SelectWindow(bufnum) < 0
      call s:OpenBuf(comd, '+'.bufnum.'buffer')
    endif
  else
    let bufname = s:GenBufName_Names(s:server, a:channel)
    call s:OpenBuf(comd, bufname)
    call s:InitBuf_Names(bufname, a:channel)
  endif
endfunction

function! s:OpenBuf_Command()
  if !(s:GetVimVar('s:opened') && s:IsBufIRC())
    return
  endif

  " Set the current server appropriately, so the command/message will be sent
  " to the one user intended
  if exists('b:server')
    call s:SetCurrentServer(b:server)
  endif

  let channel = s:GetVimVar('b:channel')
  let dccchat = !(match(channel, '='))
  let bufnum  = s:GetBufNum_Command(channel)

  if !(dccchat || bufnum == bufnr('%')) && strlen(channel)
    let query = getbufvar(bufnum, 'query')
    " Meaning, user hit i/I in a channel window, but the corresponding command
    " window was in use as a query window
    if strlen(query) && s:GetConf_YN("Are you going to post to the channel?".
	  \" not to ".query."?")
      call setbufvar(bufnum, 'query', '')
    endif
  endif

  " TODO: I think I should make it configurable where to open
  if 0
    let comd = 'botright 1split'
  else
    let comd = 'belowright 1split'
    if !dccchat
      call s:SelectWindow(strlen(channel) ? s:GetBufNum_Channel(channel)
	    \				  : s:GetBufNum_Server())
    endif
  endif

  if bufnum >= 0
    if s:SelectWindow(bufnum) < 0
      call s:OpenBuf(comd, '+'.bufnum.'buffer')
    endif
  else
    let bufname = s:GenBufName_Command(s:server, channel)
    call s:OpenBuf(comd, bufname)
    call s:InitBuf_Command(bufname, channel)
    if dccchat
      let b:query = channel
    endif
  endif
  call s:SetCommandMode(channel)
  if 1 && !&l:winfixheight
    setlocal winfixheight
  endif

  match none
  if strlen(getline('$'))
    call append('$', '')
  endif
  $
  " FIXME: Sometimes entering insert mode fails
  startinsert
endfunction

function! s:OpenBuf_Chat(nick, server)
  let bufnum = s:GetBufNum_Chat(a:nick, a:server)
  let comd = 'botright split'
  if bufnum >= 0
    if s:SelectWindow(bufnum) < 0
      call s:OpenBuf(comd, '+'.bufnum.'buffer')
    endif
  else
    let bufname = s:GenBufName_Chat(a:nick, a:server)
    call s:OpenBuf(comd, bufname)
    call s:InitBuf_Chat(bufname, a:nick, a:server)
  endif
endfunction

function! s:DoSettings()
  setlocal bufhidden=hide
  setlocal buftype=nofile
  setlocal nolist
  setlocal noswapfile
  setlocal nonumber
  setlocal wrap
  nnoremap <buffer> <silent> i	      :call <SID>OpenBuf_Command()<CR>
  nnoremap <buffer> <silent> I	      :call <SID>OpenBuf_Command()<CR>
  nnoremap <buffer> <silent> <Space>  :call <SID>MainLoop()<CR>
endfunction

function! s:DoHilite()
  " NOTE: I'm really bad at syntax highlighting.  It's horrible
  " NOTE: Do not overdo.  It'll slow things down
  syntax match VimIRCUserHead display "^\S\+\%( \S\+:\)\=" contains=@VimIRCUserName
  syntax match VimIRCTime display "^\d\d:\d\d" containedin=VimIRCUserHead contained
  syntax match VimIRCBullet display "[*!]" containedin=VimIRCUserHead contained
  " User names
  syntax cluster VimIRCUserName contains=VimIRCUserPrivmsg,VimIRCUserNotice,VimIRCUserAction,VimIRCUserQuery
  syntax match VimIRCUserPrivmsg  display "<\S\+>" contained
  syntax match VimIRCUserNotice	  display "\[\S\+\]" contained
  syntax match VimIRCUserAction	  display "\*\S\+\*" contained
  syntax match VimIRCUserQuery	  display "?\S\+?" containedin=VimIRCUserHead contained

  highlight link VimIRCTime	    String
  highlight link VimIRCUserHead	    PreProc
  highlight link VimIRCBullet	    WarningMsg
  highlight link VimIRCUserPrivmsg  Identifier
  highlight link VimIRCUserNotice   Statement
  highlight link VimIRCUserAction   WarningMsg
  highlight link VimIRCUserQuery    Question
endfunction

function! s:DoHilite_Server()
  if !s:singlewin
    call s:DoHilite()
  else
    call s:DoHilite_Channel()
  endif
  syntax region VimIRCUnderline matchgroup=VimIRCIgnore start="" end=""

  highlight link VimIRCUnderline    Underlined
  highlight link VimIRCIgnore	    Ignore
endfunction

function! s:DoHilite_List()
  syntax match VimIRCListChan "^[&#+!]\S\+ \d\+" contains=VimIRCListMember
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

function! s:DoHilite_Names()
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

function! s:InitBuf_Server(bufname)
  let b:server	= s:server
  let b:umode	= ''
  let b:title	= '  '.s:nick.' @ '.s:server
  call s:DoSettings()
  call s:DoHilite_Server()
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

function! s:InitBuf_List(bufname)
  let b:server	= s:server
  let b:title	= '  List of channels @ '.s:server
  call s:DoSettings()
  setlocal nowrap
  nnoremap <buffer> <silent> <CR> :call <SID>JoinChannel()<CR>
  " I take Mutt's keys
  nnoremap <buffer> <silent> o	  :call <SID>SortSelect()<CR>
  nnoremap <buffer> <silent> O	  :call <SID>SortReverse()<CR>
  call s:DoHilite_List()
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

function! s:InitBuf_Channel(bufname, channel)
  let b:server	= s:server
  let b:channel = a:channel
  let b:cmode	= ''
  let b:topic	= ''
  let b:title	= '  '.a:channel.' @ '.s:server

  call s:DoSettings()
  call s:DoHilite_Channel()
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

function! s:InitBuf_Names(bufname, channel)
  let b:server	= s:server
  let b:channel = a:channel
  let b:title	= a:channel
  call s:DoSettings()
  call s:DoHilite_Names()
  setlocal nowrap
  nnoremap <buffer> <silent> <CR> :call <SID>SelectNickCmd(0)<CR>
  vnoremap <buffer> <silent> <CR> :call <SID>SelectNickCmd(0)<CR>
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

function! s:InitBuf_Command(bufname, channel)
  let b:query	= ''
  let b:server	= s:server
  let b:channel = a:channel
  call s:DoSettings()
  nnoremap <buffer> <silent> <CR> :call <SID>SendingCommand()<CR>
  inoremap <buffer> <silent> <CR> <Esc>:call <SID>SendingCommand()<CR>
  nunmap <buffer> i
  nunmap <buffer> I
  " TODO: Forbid gq stuffs
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

function! s:InitBuf_Chat(bufname, nick, server)
  " NOTE: a:server is the name of the IRC server, not the peer's
  let b:server	= a:server
  let b:channel = '='.a:nick
  let b:title	= '  Chatting with '.a:nick
  call setline(1, s:GetTime(1).' *: Now chatting with '.a:nick)
  call s:DoSettings()
  call s:DoHilite_Chat()
  call s:SetBufNum(a:bufname, bufnr('%'))
endfunction

"
" And closing
"

function! s:CloseServer()
  " Close other related windows before closing the server window
  call s:CloseCommand(1)
  call s:CloseList()

  let v:errmsg = ''
  while s:VisitServer() >= 0
    silent! close
    if strlen(v:errmsg)
      break
    endif
  endwhile
endfunction

function! s:CloseList()
  let bufnum = s:GetBufNum_List()
  if bufnum >= 0
    while s:SelectWindow(bufnum) >= 0
      silent! close
    endwhile
  endif
endfunction

function! s:CloseChannel(channel)
  " XXX: No fear of endless loop?
  let bufnum = s:GetBufNum_Channel(a:channel)
  if bufnum >= 0
    while s:SelectWindow(bufnum) >= 0
      silent! close
    endwhile
  endif

  let bufnum = s:GetBufNum_Names(a:channel)
  if bufnum >= 0
    while s:SelectWindow(bufnum) >= 0
      silent! close
    endwhile
  endif
  redraw
endfunction

function! s:CloseCommand(force)
  if exists('s:channel')
    let bufnum = s:GetBufNum_Command(s:channel)
    if bufnum >= 0 && s:SelectWindow(bufnum) >= 0
      call s:PreBufModify()
      if line('.') != line('$')
	move $
      endif
      call s:BufTrim()
      " Remove duplicates, if any
      if line('$') > 1
	call s:ExecuteSafe('keepjumps', 'normal! G$')
	while search('^\V'.getline('$').'\$', 'w') && line('.') != line('$')
	  delete _
	  .-1
	endwhile
      endif
      call s:PostBufModify()
      if a:force || !strlen(b:query)	" don't close if in query mode
	while s:SelectWindow(bufnum) >= 0
	  silent! close
	endwhile
	" Move the cursor back onto the channel where command mode was
	" triggered.
	if strlen(s:channel)
	  call s:VisitChannel(s:channel)
	endif
      endif
      redraw
    endif
  endif
endfunction

function! s:CloseChat(nick, server)
  let save_server = s:server
  let s:server = a:server

  let bufnum = s:GetBufNum_Command('='.a:nick)
  if bufnum >= 0
    let v:errmsg = ''
    while s:SelectWindow(bufnum) >= 0
      silent! close
      if strlen(v:errmsg)
	break
      endif
    endwhile
  endif

  let bufnum = s:GetBufNum_Chat(a:nick, a:server)
  if bufnum >= 0
    let v:errmsg = ''
    while s:SelectWindow(bufnum) >= 0
      silent! close
      if strlen(v:errmsg)
	break
      endif
    endwhile
  endif

  let s:server = save_server
  redraw
endfunction

function! s:CloseVimIRC()
  wincmd b
  let v:errmsg = ''
  while 1
    if !match(bufname('%'), s:bufname_prefix)
      silent! close
      if strlen(v:errmsg)
	enew
	break
      endif
    else
      let winnum = winnr()
      wincmd W
      if winnr() == winnum
	break
      endif
    endif
  endwhile
endfunction

"
" Providing some user interaction
"

function! s:HandleKey(key)
  let char   = nr2char(a:key)
  let oldwin = winnr()
  let search = (char =~# '[/?Nn]')

  match none
  " TODO: Make some mappings user-configurable
  " TODO: Characterwise motions?
  if char =~# '[:]'
    " TODO: How can we enter ex command mode from script?  Requires a new vim
    "	    command (startex or something)?
    if 0
      throw 'IMGONNAEX'
    else
      let comd = input(':')
      if strlen(comd)
	execute comd
      endif
      echo ""
    endif
  elseif char =~# '[iI]'
    call s:OpenBuf_Command()
    throw 'IMGONNAPOST'
  elseif char =~# '[/?]'
    call s:SearchWord(char)
  elseif char == "\<CR>"
    if s:IsBufCommand()
      call s:SendingCommand()
    elseif s:IsBufList()
      call s:JoinChannel()
      echo ""
    elseif s:IsBufNames()
      call s:SelectNickCmd(1)
    else
      execute 'normal!' char
    endif
  elseif char =~# '[oO]'
    if s:IsBufList()
      call s:Sort{char ==# 'o' ? 'Select' : 'Reverse'}()
    endif
  elseif char =~# '[bp]'	" scroll backward
    execute 'normal!' nr2char(2)
  elseif char =~# '[ ]'		" scroll forward
    execute 'normal!' nr2char(6)
  elseif char == "\<C-B>" || char == "\<C-F>"
	\ || char == "\<C-D>" || char == "\<C-U>"
	\ || char == "\<C-E>" || char == "\<C-Y>"
	\ || char == "\<C-L>" || char == "\<C-P>"
	\ || char =~# '[$+-0GHLMNjkn^]'
    " One char commands
    silent! execute 'normal!' char
  elseif char =~# '[`gmz]'
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
    silent! execute 'normal!' comd
  endif
  " Discard excessive keytypes (Chalice)
  while getchar(0)|endwhile

  if winnr() != oldwin
    call s:UpdateTitleBar()
  endif
  call s:Hilite{search ? 'Column' : 'Line'}('.')
  redraw
endfunction

function! s:SendingCommand()
  " TODO: Do confirmation (preferably optionally)
  if !s:IsBufCommand()
    return
  endif

  call s:SetCurrentServer(b:server)
  " The variable used for closing the command-line window.  Ugly, isn't it?
  let s:channel = b:channel

  let line = s:StrTrim(getline('.'))
  let comd = ''
  let args = ''

  if line[0] == '/'
    let rx = '^/\(\S\+\)\%(\s\+\(.\+\)\)\=$'
    if line =~ rx  " could this fail?  I don't know
      " TODO: Allow abbreviated forms of commands
      let comd = toupper(substitute(line, rx, '\1', ''))
      let args = substitute(line, rx, '\2', '')

      " Accept aliases
      if comd =~# '^\%(MSG\|QUERY\)$'
	if comd ==# 'QUERY'
	  " Just entering/quitting query mode, not sending.
	  " NOTE: I'm reusing the command window for querying.  Conversations
	  " will be displayed in the current server window.
	  if strlen(args)
	    call s:InitiateQuery(args)
	    return
	  else
	    let b:query = ''
	  endif
	endif
	let comd = 'PRIVMSG'
      elseif comd ==# 'ME'
	let comd = 'ACTION'
	let args = (strlen(b:query) ? b:query : b:channel).' '.args
      elseif comd =~# '^\%(LEAVE\)$'
	let comd = 'PART'
      endif

      if strlen(args)
	" This is only for removing a leading colon which user (unnecessarily)
	" appended to the MESSAGE and adding back!  Silly and redundant
	"
	" Commands with the following form:
	"   COMMAND [MESSAGE]
	if comd =~# '^\%(AWAY\|QUIT\|WALLOPS\)$'
	  let rx = '^:\=\(.\+\)$'
	  if args =~ rx
	    let args = substitute(args, rx, ':\1', '')
	  endif
	elseif comd =~# '^\%(USERHOST\|ISON\)$'
	  " User might delimit targets with commas
	  let args = s:StrCompress(substitute(args, ',', ' ', 'g'))
	else
	  let rx = ''
	  if comd =~# '^\%(PART\|TOPIC\|PRIVMSG\|NOTICE\|SQU\%(ERY\|IT\)\|KILL\|ACTION\)$'
	    " COMMAND TARGET [MESSAGE]
	    let rx = '^\(\S\+\)\s\+:\=\(.\+\)$'
	  elseif comd =~# '^\%(KICK\)$'
	    " COMMAND CHANNEL USER [MESSAGE]
	    let rx = '^\(\S\+\s\+\S\+\)\s\+:\=\(.\+\)$'
	  endif
	  if strlen(rx) && args =~ rx
	    let args = substitute(args, rx, '\1', '').' :'.substitute(args, rx,
		  \						      '\2', '')
	  endif
	endif
      endif

      if comd =~# '^\%(NAMES\)$'
	" When receiving a bunch of lines, visit the server window beforehand:
	" avoid the flicker caused by cursor movement between server and
	" channel windows
	call s:VisitServer()
      endif

      if exists('*s:Send_{comd}')
	call s:Send_{comd}(comd, args)
      elseif comd ==# 'HELP'
	call s:PrintHelp()
      elseif comd ==# 'SERVER'
	call s:Server(args)
      else
	call s:SendCommand(comd, args)
      endif
    endif
  elseif strlen(line)
    let target = strlen(b:query) ? b:query : b:channel
    if strlen(target)
      " Send PRIVMSG to the current channel
      call s:SendMessage('PRIVMSG', target.' :'.line)
    else
      echo 'You are not on a channel.'
    endif
  endif

  call s:CloseCommand(0) " might have already been closed before we reach here
  unlet! s:channel
  if comd !=# 'AWAY'  " don't scroll down when awaying, to keep the context
    call s:ExecuteSafe('keepjumps', 'normal! Gzb')
  endif
  redraw
  call s:MainLoop()
endfunction

function! s:JoinChannel()
  let chan = matchstr(getline('.'), '^[&#+!]\S\+')
  if strlen(chan) && s:GetConf_YN("Join the channel ".chan."?")
    call s:SetCurrentServer(b:server)
    call s:Send_JOIN('JOIN', chan)  " first parameter can be any string i think
  endif
endfunction

function! s:InitiateQuery(nick)
  " TODO: Open up a separate window as with DCC CHAT?
  if !s:IsBufCommand()
    call s:OpenBuf_Command()
  else
    if strlen(getline('$'))
      call append('$', '')
    endif
    $
    startinsert
  endif
  let b:query = a:nick
  call s:SetCommandMode(b:channel)
endfunction

function! s:SelectNickCmd(loop) range
  if !s:IsBufNames()
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

  let nnick = a:lastline - a:firstline + 1
  let comds = "&whois\n&query\n&control\n&dcc"
  let choice= confirm("What do you do with ".nicks."?", comds)
  if !choice
    return
  endif

  if nnick > 1 && !(choice % 2)
    echo "Sorry, you cannot do it with mulitple persons at the same time"
  endif

  if choice == 1
    while strlen(nicks)
      let nick = matchstr(nicks, '^\S\+')
      call s:SendCommand('WHOIS', nick)
      let nicks = substitute(nicks, '^\S\+\s*', '', '')
    endwhile
  elseif choice == 2
    call s:InitiateQuery(nicks)
    if a:loop
      throw 'IMGONNAPOST'
    endif
    return
  elseif choice == 3
    let comds = "&1 Op\n&2 Deop\n&3 Voice\n&4 Devoice"
    let choice= confirm("Choose one of these:", comds)
    if !choice
      return
    endif

    let onoff = (choice % 2) ? '+' : '-'
    let mode  = choice >= 3 ? 'v' : 'o'
    let modes = mode

    if nnick > 1
      let i = 1
      while i < nnick
	let modes = modes.mode
	let i = i + 1
      endwhile
    endif
    call s:SendCommand('MODE', b:channel.' '.onoff.modes.' '.nicks)
  elseif choice == 4
    let comds = "&send\n&chat"
    let choice= confirm("Choose one of these:", comds)
    if !choice
      return
    endif

    let args = ''
    if choice == 1
      let fname = input("Enter filename: ")
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

  if !a:loop
    call s:MainLoop()
  endif
endfunction

function! s:SearchWord(comd)
  let word = input(a:comd)
  if strlen(word)
    let @/ = word
  endif
  silent! execute 'normal!' (a:comd == '/' ? 'n' : 'N')
endfunction

function! s:OfflineMsg()
  echo s:IsSockOpen() ? s:IsBufCommand()
	\		? 'Hitting <CR> will send out the current line'
	\		: 'Hit <Space> to get online'
	\	      : 'Do /SERVER command to get connected'
endfunction

function! s:PrintHelp()
  try
    echohl Title
    echo " VimIRC Help\n\n"
    echo " Available commands:\n\n"
    echohl None
    echo "/server host:port"
    echo "\tTry to connect with a new server.  Or reconnect the current server"
    echo "\tby omitting an argument."
    echo "/quit message"
    echo "\tDisconnect with the current server.  Message is optional."
    echo "\n"
    echo "/join channel(s)"
    echo "\tJoin specified channels. \"channels\" is a list of one or more of"
    echo "\tchannel names, separated with commas."
    echo "/part channel(s) message"
    echo "\tExit from the specified channels.  The last argument is optional."
    echo "\tIf you also omit channels, you'll exit from the current channel."
    echo "\n"
    echo "/msg target message"
    echo "\tSend a message to a nick/channel."
    echo "message"
    echo "\tSend a message to the current channel or the user currently"
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
    echo "/dcc help"
    echo "\tShow help message of DCC commands"
    echo "\n"
    echohl MoreMsg
    echo "Hit any key to continue"
    call getchar()
  finally
    echohl None
    redraw!
  endtry
endfunction

function! s:PrintHelp_DCC()
  echohl Title
  echo " Available DCC commands:\n\n"
  echohl None
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
  try
    echohl MoreMsg
    echo "Hit any key to continue"
    call getchar()
  finally
    echohl None
    redraw!
  endtry
endfunction

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
    " Which redraw is better?  Simple redrawing might cause a flicker (if the
    " update was on a different buffer than the active one), which should be
    " eye-catchy
    if 1
      redraw
    else
      call s:RedrawStatus() " show the correct line number
    endif
  endif
endfunction

function! s:UpdateTitleBar()
  let &titlestring = s:client.': '.(s:IsBufIRC()
	\			    ? b:server.' '.(s:IsBufChannel()
	\					    ? b:channel.': '.b:topic
	\					    : '')
	\			    : fnamemodify(expand('%'), ':p'))
endfunction

function! s:GetStatus()
  return exists('b:title') ? b:title  : bufname('%')
endfunction

function! s:SetUserMode(umode)
  let bufnum = s:GetBufNum_Server()
  if bufnum >= 0
    call setbufvar(bufnum, 'umode', a:umode)
    call setbufvar(bufnum, 'title', '  '.s:GetCurrentNick().
	  \' [+'.a:umode.'] @ '.s:server)
    call s:RedrawStatus(1)
    call s:UpdateTitleBar()
  endif
endfunction

function! s:SetChannelTopic(channel, topic)
  let bufnum = s:GetBufNum_Channel(a:channel)
  if bufnum >= 0
    call setbufvar(bufnum, 'topic', a:topic)
    call s:UpdateTitleBar()
  endif
endfunction

function! s:SetChannelMode(channel, cmode)
  let bufnum = s:GetBufNum_Channel(a:channel)
  if bufnum >= 0
    call setbufvar(bufnum, 'cmode', a:cmode)
    call setbufvar(bufnum, 'title', '  '.a:channel." [".a:cmode.'] @ '.s:server)
    call s:RedrawStatus(1)
  endif
endfunction

function! s:SetCommandMode(channel)
  let bufnum = s:GetBufNum_Command(a:channel)
  if bufnum >= 0
    let query = getbufvar(bufnum, 'query')
    call setbufvar(bufnum, 'title', '  '.(strlen(query)
	  \				  ? 'Querying '.query
	  \				  : 'Posting to '.
	  \(strlen(a:channel) ? a:channel.' @ ' : '').s:server))
    call s:RedrawStatus()
  endif
endfunction

"
" Misc. utility functions
"

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

function! s:SelectWindow(bufnum)
  let winnum = -1
  if a:bufnum
    let winnum = bufwinnr(a:bufnum)
    if winnum >= 0 && winnum != winnr()
      execute winnum.'wincmd w'
    endif
  endif
  return winnum
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

function! s:HiliteColumn(bogus, ...)
  execute 'match' (a:0 ? a:1 : 'Cursor') '/\%#\k*/'
endfunction

function! s:HiliteLine(lnum, ...)
  execute 'match' (a:0 ? a:1 : 'Cursor') '/^.*\%'.(a:lnum
	\					    ? a:lnum
	\					    : line(a:lnum)).'l.*$/'
endfunction

function! s:GetTime(short, ...)
  return strftime((a:short ? '%H:%M' : '%Y/%m/%d %H:%M:%S'),
	\				    (a:0 && a:1 ? a:1 : localtime()))
endfunction

function! s:RedrawStatus(...)
  if exists(':redrawstatus')
    execute 'redrawstatus'.(a:0 && a:1 ? '!' : '')
  endif
endfunction

function! s:PreBufModify()
  let s:save_undolevels = &undolevels
  set undolevels=-1
  setlocal modifiable
endfunction

function! s:PostBufModify()
  if exists('s:save_undolevels')
    let &undolevels = s:save_undolevels
    unlet s:save_undolevels
  endif
  "setlocal nomodifiable
endfunction

function! s:Input(msg, ...)
  return s:StrCompress(input(a:msg.': ', (a:0 ? a:1 : '')))
endfunction

function! s:IsBufEmpty()
  return !(line('$') > 1 || strlen(getline(1)))
endfunction

function! s:GetVimVar(varname)
  return exists('{a:varname}') ? {a:varname} : ''
endfunction

function! s:GetConf_YN(msg)
  echohl Question
  echon ' '.a:msg.' (y/[n]): '
  echohl None
  return (nr2char(getchar()) ==? 'y')
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

  let oldline = getline('.')
  call s:PreBufModify()
  call s:SortList(cmp, (s:GetVimVar('b:sortdir') + 0))
  call s:PostBufModify()
  call search('^\V'.oldline.'\$', 'w')
endfunction

function! s:SortReverse()
  if !s:IsBufList()
    return
  endif

  let lnum = line('.')
  call s:PreBufModify()
  perl $curbuf->Set(1, reverse($curbuf->Get(1 .. $curbuf->Count())))
  call s:PostBufModify()
  let b:sortdir = !(s:GetVimVar('b:sortdir'))
  execute (line('$') - lnum + 1)
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
		map { [ $_, /^\S+\s+\d+\s*:(.*)$/ ] } @lns;
    }
  $curbuf->Set(1, @lns);
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

	  ctcp_send(1, $chan, $mesg);

	  if (is_channel($chan))
	    {
	      my $nref = get_nicks($chan);
	      $nick = get_nickprefix($nref->{$nick}).$nick;
	    }

	  irc_add_line($chan, "*%s*: %s", $nick, $mesg);
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
      return s:PrintHelp_DCC()
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
	      VIM::DoCommand("call s:OpenBuf_Chat(\"$nick\",
		    \			\"$dcc->{'iserver'}->{'server'}\")");
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

function! s:Send_JOIN(comd, args)
  " TODO: What to do with 'JOIN 0'?  Especially when it is not supported by
  "	  the server?
  perl <<EOP
{
  my $chans = VIM::Eval('a:args');

  foreach my $chan (split(/,/, $chans))
    {
      if (is_channel($chan))
	{
	  VIM::DoCommand("call s:OpenBuf_Channel(\"$chan\")");
	  unless (get_channel($chan))	# not joined yet
	    {
	      irc_send("JOIN %s", $chan);
	      irc_add_line($chan, "*: Now talking in %s", $chan);
	      if (VIM::Eval('!strlen(getline(1))'))
		{
		  $curbuf->Delete(1);
		}
	      add_channel($chan);
	    }
	}
    }
}
EOP
  " I don't like to call CloseCommand() in various parts, but I just want to
  " stay here (the last opened channel)
  let bufnum = bufnr('%')
  call s:CloseCommand(1)
  call s:SelectWindow(bufnum)
endfunction

function! s:Send_LIST(comd, args)
  " MEMO: Some servers don't send "321 RPL_LISTSTART", so open a list buffer
  " befor we send the command
  call s:OpenBuf_List()
  call s:PreBufModify()
  call s:BufClear()
  call s:PostBufModify()
  call s:SendCommand(a:comd, a:args)
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
  call s:SendCommand(a:comd, substitute(nick, '\s\+', '-', 'g'))
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

  # TODO: Do quoting and encoding
  foreach my $chan (split(/,/, $chans))
    {
      if (is_channel($chan))
	{
	  irc_send("PART %s %s", $chan, $mesg);
	}
    }
}
EOP
endfunction

function! s:Send_PING(comd, args)
  if !strlen(a:args)
    return
  endif

  perl <<EOP
{
  my $comd = VIM::Eval('a:comd');
  my $args = VIM::Eval('a:args');
  my $time = VIM::Eval('localtime()');

  ctcp_send(1, $args, "%s %d", $comd, $time);
}
EOP
endfunction

function! s:Send_QUIT(comd, args)
  let mesg = strlen(a:args) ? a:args : s:partmsg
  let bufnum = s:GetBufNum_Server()
  if bufnum >= 0
    " Mark this buffer as dead so that the next /SERVER invocation will close it
    call setbufvar(bufnum, 'dead', 1)
  endif

  perl <<EOP
{
  my $mesg = VIM::Eval('l:mesg');

  while (my $chan = each(%{$Current_Server->{'chans'}}))
    {
      VIM::DoCommand("call s:CloseChannel(\"$chan\")");
    }
  delete($Current_Server->{'chans'});

  # $mesg itself already contains a leading colon
  irc_send("QUIT %s", $mesg);
}
EOP
  call s:CloseServer()
endfunction

function! s:Send_NOTICE(comd, args)
  call s:SendMessage(a:comd, a:args)
endfunction

function! s:Send_PRIVMSG(comd, args)
  call s:SendMessage(a:comd, a:args)
endfunction

function! s:SendMessage(comd, args)
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
	  irc_send("%s %s :%s", $comd, $chan, $mesg);

	  if (is_channel($chan))
	    {
	      my $nref = get_nicks($chan);
	      $nick = get_nickprefix($nref->{$nick}).$nick;
	    }

	  $priv = ($comd eq 'PRIVMSG');
	  irc_add_line($chan, "%s%s%s: %s",
			      ($priv ? '<' : '['),
			      $nick,
			      ($priv ? '>' : ']'),
			      $mesg);
	}
    }
}
EOP
endfunction

function! s:SendCommand(comd, args)
  perl <<EOP
{
  my $comd = VIM::Eval('a:comd');
  my $args = VIM::Eval('a:args');

  irc_send("%s".($args ? " %s" : ""), $comd, $args);
}
EOP
endfunction

function! s:SetCurrentServer(server)
  perl <<EOP
{
  my $server = find_server(scalar(VIM::Eval('a:server')));
  if ($server)
    {
      set_curserver(fileno($server->{'sock'}));
    }
}
EOP
endfunction

function! s:GetCurrentNick()
  " Enabling to hold different nicks across servers
  let nick = s:GetVimVar('s:nick_'.s:server)
  if !strlen(nick)
    let nick = s:nick
  endif
  return nick
endfunction

function! s:SetCurrentNick(nick)
  let s:nick_{s:server} = a:nick
  perl <<EOP
{
  $Current_Server->{'nick'} = VIM::Eval('a:nick');
}
EOP
endfunction

" Quit all connected servers at once
function! s:QuitServers()
  perl <<EOP
{
  foreach my $server (@Servers)
    {
      if ($server->{'conn'})
	{
	  $Current_Server = $server;
	  irc_send("QUIT");
	}
    }
}
EOP
  call s:ResetPerlVars()
endfunction

function! s:Server(server)
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

  call s:CloseCommand(1)
  if server !=# s:GetVimVar('s:server')
    let s:server = server
  endif

  "
  " Close the currently open server window (only if it is marked disconnected)
  let close = s:IsBufIRC() && exists('b:dead') && b:server !=# server
	\     ? bufnr('%') : 0
  call s:OpenBuf_Server()
  let b:port = port

  call s:PreBufModify()
  call {s:IsBufEmpty() ? 'setline' : 'append'}('$', s:GetTime(1).
	\' * Connecting with '.server.'...')
  call s:PostBufModify()
  $

  if close
    while s:SelectWindow(close) >= 0
      close
    endwhile
  endif
  redraw

  perl <<EOP
{
  my $port  = VIM::Eval('l:port');
  my $server= VIM::Eval('l:server');

  my $nick  = VIM::Eval('s:GetCurrentNick()');
  my $user  = VIM::Eval('s:user');
  my $realname= VIM::Eval('s:realname');
  my $umode = VIM::Eval('s:umode');

  if ($port <= 0)
    {
      $port = 6667;
    }

  $Current_Server = find_server($server);
  if ($Current_Server)
    {
      if ($Current_Server->{'conn'} && $Current_Server->{'port'} == $port)
	{
	  return;
	}
      conn_close($Current_Server);
    }
  else
    {
      $Current_Server = add_server();
      $Current_Server->{'server'} = $server;
      $Current_Server->{'nick'}	  = $nick;
    }
  $Current_Server->{'port'} = $port;

  if (conn_open($Current_Server))
    {
      conn_watchin($Current_Server);
      #$Current_Server->{'local'} = $Current_Server->{'sock'}->sockhost();

      irc_send("NICK %s", $nick);
      irc_send("USER %s %s * :%s", $user, $umode, $realname);
    }
  else
    {
      irc_add_line('', "*: Could not establish connection: %s", $!);
    }
}
EOP
endfunction

function! s:RecvData()
  let retval = 1

  perl <<EOP
{
  # MEMO: We're not using $WS currently, due to the blocking issue of syswrite
  my ($r, $w) = IO::Select->select($RS, $WS, undef, 0);
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

function! s:PerlIRC()
  " Don't use strict
  " TODO: Put these things in a separate file
  perl <<EOP

use Fcntl qw(O_RDONLY O_WRONLY O_CREAT O_EXCL O_APPEND O_TRUNC);

our @Servers;		# IRC servers
our $Current_Server;	# reference referring an element of @Servers
our %Clients;		# clients connected over dcc protocol
our ($RS, $WS);		# IO::Select object

our $From_Server;	# simple string value of the last sender's name@host
			# well, not used.  and should be renamed

our ($ENC_VIM, $ENC_IRC);

# Server entries will not be removed.

sub add_server
{
  my $server = {  server  => undef,
		  port	  => 0,
		  local	  => undef,
		  sock	  => undef,
		  conn	  => 0,
		  nick	  => undef,
		  away	  => 0,
		  motd	  => 0,
		  chans	  => {},
		  lastbuf => undef };

  unshift(@Servers, $server);
  return $server;
}

sub find_server
{
  my $server = shift;

  foreach my $candid (@Servers)
    {
      if ($server eq $candid->{'server'})
	{
	  return $candid;
	}
    }
  return undef;
}

sub set_curserver
{
  my $fd = shift;

  foreach my $server (@Servers)
    {
      if ($fd == fileno($server->{'sock'}))
	{
	  $Current_Server = $server;
	  VIM::DoCommand("let s:server = \"$server->{'server'}\"");
	  last;
	}
    }
}

sub irc_add_line
{
  my $chan  = shift;
  # TODO: Use sprintf?
  my $format= shift;
  my $cname;
  # Remember the current window
  my $wnum  = VIM::Eval('winnr()');

  # Data for hidden channels might be discarded, which is not desirable
  unless (is_channel($chan) && VIM::Eval("s:VisitChannel(\"$chan\")"))
    {
      unless (VIM::Eval("s:VisitServer()"))
	{
	  return;
	}
      if (is_channel($chan))
	{
	  $cname = "($chan)";
	}
    }

  VIM::DoCommand('call s:PreBufModify()');
  # I think Vim's strftime is much faster than perl's equivalent
  $curbuf->Append($curbuf->Count(), sprintf("%s %s$format",
					    scalar(VIM::Eval('s:GetTime(1)')),
					    $cname,
					    @_));
  unless ($Current_Server->{'away'})
    {
      # Shouldn't scroll down nor beep while you're away
      VIM::DoCommand('call s:NotifyNewEntry()');
    }
  VIM::DoCommand('call s:PostBufModify()');
  VIM::DoCommand("${wnum}wincmd w");
  VIM::DoCommand('redraw');
}

sub irc_recv
{
  my $sock = shift;
  my ($buffer, @lines);

  set_curserver(fileno($sock));

  unless (sysread($sock, $buffer, 2048))
    {
      set_connected(0);
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
  my $format= shift;
  my @args  = @_;

  if ($ENC_VIM && $ENC_IRC)
    {
      foreach my $arg (@args)
	{
	  Encode::from_to($arg, $ENC_VIM, $ENC_IRC);
	}
    }
  syswrite($Current_Server->{'sock'}, sprintf("$format\x0D\x0A", @args));
}

sub set_connected
{
  my $conn = shift;

  $Current_Server->{'conn'} = $conn;
  unless ($conn)
    {
      $Current_Server->{'motd'} = 0;
      $Current_Server->{'lastbuf'} = undef;
      conn_close($Current_Server);
    }
}

sub conn_close
{
  my $server = shift;

  if ($server->{'sock'})
    {
      $RS->remove($server->{'sock'});

      if (defined($WS) && $WS->exists($server->{'sock'}))
	{
	  $WS->remove($server->{'sock'});
	}

      #$server->{'sock'}->shutdown(2);
      $server->{'sock'}->close();
    }
}

sub conn_open
{
  use IO::Socket;

  my $server = shift;
  my $sock = IO::Socket::INET->new( PeerAddr  => $server->{'server'},
				    PeerPort  => $server->{'port'},
				    Proto     => 'tcp',
				    Timeout   => 10
				  );
  if ($sock)
    {
      $server->{'sock'} = $sock;
    }
  return defined($sock);
}

sub conn_watchin
{
  my $server = shift;

  if (defined($server->{'sock'}))
    {
      unless (defined($RS))
	{
	  use IO::Select;
	  $RS = IO::Select->new();
	}
      $RS->add($server->{'sock'});
    }
}

sub conn_watchout
{
  my $server = shift;

  if (defined($server->{'sock'}))
    {
      unless (defined($WS))
	{
	  $WS = IO::Select->new();
	}
      $WS->add($server->{'sock'});
    }
}

sub is_channel
{
  # TODO: This might not be enough
  return (shift =~ /^[&#+!]/);
}

sub is_me
{
  return (shift eq $Current_Server->{'nick'});
}

#
# CTCP
#

# Heavily based on ircii and x-chat, regarding the DCC part

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
  my $target = shift;
  irc_send("%s %s :\x01%s\x01", ($query ? 'PRIVMSG' : 'NOTICE'), $target,
							  sprintf(shift, @_));
}

sub process_ctcp_query
{
  my ($from, $pref, $chan, $mesg) = @_;

  while (${$mesg} =~ s/\x01(.*?)\x01//)
    {
      # TODO: flood-protection codes here
      if (my ($comd, $args) = ($1 =~ /^(\S+)(?:\s*(.+))?$/))
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
	      irc_add_line($chan, "*%s%s*: %s", $pref, $from, $args);
	    }
	  else
	    {
	      irc_add_line($chan, "?%s%s?: %s %s", $pref, $from, $comd, $args);
	      if ($comd eq 'ECHO' || $comd eq 'PING')
		{
		  ctcp_send(0, $from, "%s %s", $comd, $args);
		}
	      elsif ($comd eq 'TIME')
		{
		  my $time = VIM::Eval('s:GetTime(0)');
		  ctcp_send(0, $from, "%s :%d", $comd, $time);
		}
	      elsif ($comd eq 'VERSION')
		{
		  my $client = VIM::Eval('s:client');
		  ctcp_send(0, $from, "%s :%s", $comd, $client);
		}
	      else
		{
		  # TODO:
		  ctcp_send(0, $from, "ERRMSG %s :unknown query", $comd);
		}
	    }
	}
    }

  return length(${$mesg});
}

sub process_ctcp_reply
{
  my ($from, $pref, $chan, $mesg) = @_;

  if (${$mesg} =~ s/\x01(.*?)\x01//)
    {
      if (my ($comd, $args) = ($1 =~ /^(\S+)(?:\s*(.+))?$/))
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
	      my $diff = scalar(VIM::Eval('localtime()')) - $args;
	      irc_add_line('', "[%s%s(%s)]: %d seconds delay",
				$pref, $from, $comd, $diff);
	    }
	  else
	    {
	      irc_add_line('', "[%s%s(%s)]: %s", $pref, $from, $comd, $args);
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
	  else
	    {
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
		  $dcc->{'fname'} = sprintf("%s/%s", $dccdir,
							do_urldecode($fname));
		  $dcc->{'fsize'} = $size;

		  if (-e $dcc->{'fname'})
		    {
		      # FIXME: Append seems to corrupt data
		      if (0 && (my $fsize = (-s $dcc->{'fname'})) < $size)
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
		      do_escape($dcc->{'nick'}),
		      (($dcc->{'flags'} & $DCC_TYPE) == $DCC_FILERECV
			? 'SEND'
			: $DCC_TYPES[$dcc->{'flags'} & $DCC_TYPE]));

  VIM::DoCommand("call s:Beep(2)");
  return scalar(VIM::Eval("s:GetConf_YN(\"$mesg\")"));
}

sub dcc_show_list
{
  irc_add_line('', "*: Listing DCC sessions");

  foreach my $server (@Servers)
    {
      if (exists($Clients{$server->{'server'}}))
	{
	  irc_add_line('', "DCC(LIST): Via %s:", $server->{'server'});
	  foreach my $dcc (@{$Clients{$server->{'server'}}})
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
  irc_add_line('', "*: End of DCC list");
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

sub dcc_add_line
{
  my ($dcc, $itsme) = @_;
  my $bnum = VIM::Eval("bufnr('%')");

  VIM::DoCommand("call s:OpenBuf_Chat(\"$dcc->{'nick'}\",
	\				\"$dcc->{'iserver'}->{'server'}\")");
  VIM::DoCommand("call s:PreBufModify()");

  foreach my $line (split(/\x0D?\x0A/, $dcc->{'linebuf'}))
    {
      my $action = ($line =~ s/^\x01ACTION (.*?)\x01/$1/);

      if ($ENC_VIM && $ENC_IRC)
	{
	  Encode::from_to($mesg, $ENC_IRC, $ENC_VIM);
	}
      $curbuf->Append($curbuf->Count(),
		      sprintf("%s %s%s%s: %s",
			      scalar(VIM::Eval("s:GetTime(1)")),
			      ($action ? '*' : '='),
			      ($itsme
				? $dcc->{'iserver'}->{'nick'}
				: $dcc->{'nick'}),
			      ($action ? '*' : '='),
			      $line));
    }

  VIM::DoCommand("call s:PostBufModify()");
  VIM::DoCommand("call s:NotifyNewEntry()");
  VIM::DoCommand("call s:SelectWindow($bnum)");
  VIM::DoCommand("redraw");
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
  my $fd = shift;

  foreach my $server (@Servers)
    {
      if (exists($Clients{$server->{'server'}}))
	{
	  foreach my $dcc (@{$Clients{$server->{'server'}}})
	    {
	      if ($fd == fileno($dcc->{'sock'}))
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
  my $candid;

  foreach my $dcc (@{$Clients{$Current_Server->{'server'}}})
    {
      if ($dcc->{'flags'} & $DCC_FAILED)  # do not return closed/rejected one
	{
	  next;
	}
      if ($nick && ($dcc->{'nick'} ne $nick))
	{
	  next;
	}
      if ($type && !(($dcc->{'flags'} & $DCC_TYPE) == $type))
	{
	  next;
	}
      if ($desc && ($dcc->{'desc'} ne $desc))
	{
	  next;
	}
      $candid = $dcc;
    }

  return $candid;
}

sub del_dccclient
{
  my $dcc = shift;

  foreach my $server (@Servers)
    {
      if (exists($Clients{$server->{'server'}}))
	{
	  my $clients = $Clients{$server->{'server'}};

	  for (my $i = 0; $i <= $#{$clients}; $i++)
	    {
	      if ($dcc == ${$clients}[$i])
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
      irc_add_line('', "DCC(%s): Opening socket failed: %s",
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
}

sub dcc_they_accept
{
  my $dcc = shift;

  if (conn_open($dcc))
    {
      $dcc->{'flags'} &= ~$DCC_QUEUED;
      $dcc->{'flags'} |= $DCC_ACTIVE;
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

  if (0)
    {
      # TODO: transfer statistics or something here?
    }

  # XXX: Delete it by default?  Or should we wait a few seconds?
  if (!defined($destroy) || $destroy)
    {
      if (   (($dcc->{'flags'} & $DCC_TYPE) == $DCC_CHATRECV)
	  || (($dcc->{'flags'} & $DCC_TYPE) == $DCC_CHATSEND))
	{
	  VIM::DoCommand("call s:CloseChat(\"$dcc->{'nick'}\",
		\			  \"$dcc->{'iserver'}->{'server'}\")");
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
      if (substr($dcc->{'linebuf'}, -1) ne "\x0A")
	{
	  # XXX: I've never seen this yet, but it could happen...
	  vim_printf('LINE NOT ENDING WITH \n!');
	}
      $dcc->{'bytesread'} += $bytesread;
      dcc_add_line($dcc);
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
	  dcc_add_line($dcc, 1);
	}
    }
}

sub dcc_check
{
  my ($sock, $write) = @_;
  my $dcc = find_dccclient_fd(fileno($sock));

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
	      # MEMO: `send' flag must already have been dropped off
	      dcc_recv_chat($dcc);
	    }
	}
    }
  return 1;
}

#
# Channel/User management
#

our $UMODE_CHOP	  = 0x01;
our $UMODE_VOICE  = 0x02;

sub set_umode
{
  my ($from, $modes) = @_;

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

  irc_add_line('', "*: %s sets mode: +%s", $from, $Current_Server->{'umode'});
  VIM::DoCommand("call s:SetUserMode(\"$Current_Server->{'umode'}\")");
}

sub set_cmode
{
  my ($chan, $mode) = @_;
  my $cref = get_channel($chan);
  my $nref = get_nicks($chan);

  while ($mode =~ s/^\s*([+-])(\S+)((?:\s+(?:[^+-]\S+))*)//)
    {
      my $add = ($1 eq '+');
      my $arg = $3;
      my ($val, $nicks);

      for ($2)
	{
	  if (/o/i)
	    {
	      $val  = $UMODE_CHOP;
	      $nicks= $arg;
	      last;
	    }
	  if (/v/)
	    {
	      $val  = $UMODE_VOICE;
	      $nicks= $arg;
	      last;
	    }
	}

      if ($nicks)
	{
	  foreach my $nick (split(/ +/, $nicks))
	    {
	      next unless $nick;

	      if ($add)
		{
		  $nref->{$nick} |= $val;
		  if (is_me($nick))
		    {
		      $cref->{'umode'} |= $val;
		    }
		}
	      else
		{
		  $nref->{$nick} &= ~$val;
		  if (is_me($nick))
		    {
		      $cref->{'umode'} &= ~$val;
		    }
		}
	      list_nicks($chan);
	    }
	}
      else
	{
	  if ($add)
	    {
	      $cref->{'cmode'} |= $val;
	    }
	  else
	    {
	      $cref->{'cmode'} &= ~$val;
	    }
	}
    }
}

sub add_channel
{
  my $chan = shift;
  # We should not change the case when adding channels.  It may cause troubles
  # with non-ascii characters

  unless (get_channel($chan))
    {
      $Current_Server->{'chans'}->{$chan} = { cname => $chan,
					      umode => 0,
					      cmode => 0,
					      nicks => {}   };
    }
}

sub get_channel
{
  my $name = lc(shift);
  my $cref;

  # We have to compare channel names one by one, ignoring case
  # XXX: Iterating over the same hash with each() could cause an endless loop
  #	 if done recursively.  TOO DANGEROUS!
  foreach my $chan (keys(%{$Current_Server->{'chans'}}))
    {
      if ($name eq lc($chan))
	{
	  $cref = $Current_Server->{'chans'}->{$chan};
	  last;
	}
    }
  return $cref;
}

sub del_channel
{
  my $chan = shift;

  if (my $cref = get_channel($chan))
    {
      delete($Current_Server->{'chans'}->{$cref->{'cname'}});
    }
  VIM::DoCommand("call s:CloseChannel(\"$chan\")");
}

sub get_nicks
{
  my $cref = get_channel(shift);
  return $cref->{'nicks'};
}

sub get_nickprefix
{
  my $mode = shift;
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

sub add_nick
{
  my ($nick, $mode, $chan) = @_;
  my $cref = get_channel($chan);

  if (is_me($nick))
    {
      $cref->{'umode'} = $mode;
    }
  $cref->{'nicks'}->{$nick} = $mode;
}

sub del_nick
{
  my ($nick, $chan) = @_;
  my $nref = get_nicks($chan);

  if (exists($nref->{$nick}))
    {
      delete($nref->{$nick});
      return 1;
    }
  return 0;
}

sub rename_nick
{
  my ($old, $new, $chan) = @_;
  my $nref = get_nicks($chan);

  if (exists($nref->{$old}))
    {
      my $mode = $nref->{$old};
      del_nick($old, $chan);
      add_nick($new, $mode, $chan);
    }
  return exists($nref->{$new});
}

sub list_nicks
{
  my $chan = shift;

  if (VIM::Eval("s:VisitChannel(\"$chan\")"))
    {
      my $nref = get_nicks($chan);
      my @nicks= map { get_nickprefix($nref->{$_}).$_ } keys(%{$nref});
      # Use bufnum since window number can change
      my $bnum = VIM::Eval("bufnr('%')");
      VIM::DoCommand("call s:OpenBuf_Names(\"$chan\")");
      VIM::DoCommand('call s:PreBufModify()');
      $curbuf->Delete(1, $curbuf->Count());

      foreach my $nick (sort { lc($b) cmp lc($a) } @nicks)
	{
	  $curbuf->Append(0, $nick);
	}

      $curbuf->Delete($curbuf->Count());
      VIM::DoCommand('call s:PostBufModify()');
      VIM::DoCommand("call s:SelectWindow($bnum)");
      VIM::DoCommand('redraw');
    }
}

#
# Parsing IRC messages
#

sub parse_number
{
  my ($from, $comd, $args) = @_;
  my ($nick, $mesg) = (${$args} =~ /^(\S+) :?(.*)$/);

  if (0)
    {
      vim_printf("from=%s comd=%s args=\"%s\"", $from, $comd, ${$args});
    }

  if ($comd == 001)	# RPL_WELCOME
    {
      set_connected(1);
      irc_add_line('', $mesg);
      unless (is_me($nick))	# user had to change nick when connecting
	{
	  VIM::DoCommand("call s:SetCurrentNick(\"$nick\")");
	}
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
	  irc_add_line('', "*: Your user mode is: +%s", $1);
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
      if (my ($nick, $mesg) = ($mesg =~ /^(\S+) :(.*)$/))
	{
	  irc_add_line('', "%s is away: %s", $nick, $mesg);
	}
    }
  elsif ($comd == 302)	# RPL_USERHOST
    {
      # Get the first one.  This should be called upon logon, to obtain the
      # hostname of the user.  Necessary for dcc things.
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
      $Current_Server->{'away'} = ($comd == 306);
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
      if (my ($nick, $server) = ($mesg =~ /^(\S+) (.*)$/))
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
      if (my ($nick, $idle, $signon) = ($mesg =~ /^(\S+) (\d+)(?: (\d+))?/))
	{
	  $idle = sprintf("%02d:%02d:%02d",
			  ($idle / 3600),
			  (($idle % 3600) / 60),
			  ($idle % 60));
	  irc_add_line('', "%s has been idle for %s%s",
			  $nick,
			  $idle,
			  ($signon
			    ? ', signed on '.VIM::Eval("s:GetTime(0, $signon)")
			    : ''));
	}
    }
  elsif ($comd == 318 || $comd == 369)	# RPL_ENDOFWHOIS
    {
      if (my ($nick, $mesg) = ($mesg =~ /^(\S+) :?(.*)$/))
	{
	  irc_add_line('', "%s %s", $nick, $mesg);
	}
    }
  elsif ($comd == 319)	# RPL_WHOISCHANNELS
    {
      if (my ($nick, $chan) = ($mesg =~ /^(\S+) :(.*)$/))
	{
	  irc_add_line('', "%s on %s", $nick, $chan);
	}
    }
  elsif ($comd == 320)	#
    {
      if (my ($nick, $mesg) = ($mesg =~ /^(\S+) :(.*)$/))
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
      # XXX: It's too unefficient to do this all the time.
      if (VIM::Eval('s:VisitList()'))
	{
	  $curbuf->Append($curbuf->Count(), $mesg);
	}
    }
  elsif ($comd == 323)	# RPL_LISTEND
    {
      if (VIM::Eval('s:VisitList()'))
	{
	  VIM::DoCommand('call s:BufTrim()|call s:HiliteLine(".")');
	  irc_add_line('', $mesg);
	}
    }
  elsif ($comd == 324)	# RPL_CHANNELMODEIS
    {
      if (my ($chan, $mode) = ($mesg =~ /^(\S+) :?(\S+)/))
	{
	  VIM::DoCommand("call s:SetChannelMode(\"$chan\", \"$mode\")");
	}
    }
  elsif ($comd == 329)
    {
      if (my ($chan, $time) = ($mesg =~ /^(\S+) (\d+)$/))
	{
	  $time = VIM::Eval("s:GetTime(0, $time)");
	  irc_add_line($chan, "*: %s came into existence on %s", $chan, $time);
	}
    }
  elsif ($comd == 331)	# RPL_NOTOPIC
    {
      if (my ($chan, $mesg) = ($mesg =~ /^(\S+) :?(.*)$/))
	{
	  irc_add_line($chan, "*: %s", $mesg);
	}
    }
  elsif ($comd == 332)	# RPL_TOPIC
    {
      if (my ($chan, $topic) = ($mesg =~ /^(\S+) :(.*)$/))
	{
	  irc_add_line($chan, "*: Topic for %s:", $chan);
	  irc_add_line($chan, "*: %s", $topic);
	  if (get_channel($chan))
	    {
	      VIM::DoCommand("call s:SetChannelTopic(\"$chan\", \"$topic\")");
	    }
	}
    }
  elsif ($comd == 333)
    {
      if (my ($chan, $nick, $time) = ($mesg =~ /^(\S+) (\S+) (\d+)$/))
	{
	  irc_add_line($chan, "*: Topic set by %s at %s", $nick,
				    scalar(VIM::Eval("s:GetTime(0, $time)")));
	}
    }
  elsif ($comd == 352)	# RPL_WHOREPLY
    {
      my ($chan, $user, $host, $server, $nick, $flag, $hop, $real) =
		($mesg =~ /^(\S+) (\S+) (\S+) (\S+) (\S+) (.*?) :(\d+) (.*)$/);
      irc_add_line('', "%s %s %s %s@%s (%s)", $chan, $nick, $flag, $user,
								$host, $real);
    }
  elsif ($comd == 353)	# RPL_NAMREPLY
    {
      my ($type, $chan, $nicks) = ($mesg =~ /^(.) (\S+) :(.*)$/);

      if (get_channel($chan))
	{
	  foreach my $nick (split(/ /, $nicks))
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
	      add_nick($nick, $mode, $chan);
	    }
	}
      else
	{
	  irc_add_line('', "*: Names for %s: %s", $chan, $nicks);
	}
    }
  elsif ($comd == 366)	# RPL_ENDOFNAMES
    {
      my ($chan) = ($mesg =~ /^(\S+)/);

      if (get_channel($chan))
	{
	  list_nicks($chan);
	}
      else
	{
	  irc_add_line('', "*: End of names");
	}
    }
  elsif ($comd == 372)	# RPL_MOTD
    {
      irc_add_line('', $mesg);
    }
  elsif ($comd == 375)	# RPL_MOTDSTART
    {
      irc_add_line('', $mesg);
    }
  elsif ($comd == 376)	# RPL_ENDOFMOTD
    {
      irc_add_line('', $mesg);
      unless ($Current_Server->{'motd'})
	{
	  $Current_Server->{'motd'} = 1;
	  irc_send("USERHOST %s", $Current_Server->{'nick'});
	  irc_send("MODE %s %s", $Current_Server->{'nick'},
						scalar(VIM::Eval('s:umode')));
	}
    }
  elsif ($comd == 391)	# RPL_TIME
    {
      irc_add_line('', $mesg);
    }
  elsif ($comd >= 431 && $comd <= 433)	# ERR_NICKNAMEINUSE etc.
    {
      irc_add_line('', $mesg);
      unless ($Current_Server->{'conn'})
	{
	  VIM::DoCommand("call s:Send_NICK('NICK', '')");
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
      irc_add_line('', "!: %s invites you to the channel %s", $from, $chan);
      # TODO: Ask user whether to join the channel
      if (0 && VIM::Eval("s:GetConf_YN()"))
	{
	  # call s:Send_JOIN()
	}
    }
}

sub parse_join
{
  my ($from, $args) = @_;

  if (my ($chan) = (${$args} =~ /^:?(\S+)/))
    {
      add_nick($from, 0, $chan);
      irc_add_line($chan, "->: Enter %s", $from);
      # If it is you who is entering, get the channel mode.
      if (is_me($from))
	{
	  irc_send("MODE %s", $chan);
	}
      list_nicks($chan);
    }
}

sub parse_kick
{
  my ($from, $args) = @_;

  if (my ($chan, $nick, $mesg) = (${$args} =~ /^(\S+) (\S+) :(.*)$/))
    {

      del_nick($nick, $chan);

      if (is_me($nick))
	{
	  irc_add_line('',
		      "!: You have been kicked out of channel %s by %s (%s)",
		      $chan, $from, $mesg);
	  del_channel($chan);
	}
      else
	{
	  irc_add_line($chan, "!: %s kicks out %s (%s)", $from, $nick, $mesg);
	  list_nicks($chan);
	}
    }
}

sub parse_mode
{
  my ($from, $args) = @_;

  if (my ($chan, $mode) = (${$args} =~ /^(\S+) :?(.*?)\s*$/))
    {
      if (is_channel($chan))
	{
	  set_cmode($chan, $mode);
	  irc_add_line($chan, "*: %s sets new mode: %s", $from, $mode);
	  if (0)
	    {
	      VIM::DoCommand("call s:SetChannelMode(\"$chan\", \"$mode\")");
	    }
	}
      else
	{
	  # Should be about yourself, right?
	  set_umode($chan, $mode);
	}
    }
}

sub parse_nick
{
  my ($from, $args) = @_;

  if (my ($nick) = (${$args} =~ /^:(.*)$/))
    {
      if (is_me($from))
	{
	  irc_add_line('', "*: New nick %s approved", $nick);
	  VIM::DoCommand("call s:SetCurrentNick(\"$nick\")");
	  irc_send("MODE %s", $nick);
	}
      foreach my $chan (keys(%{$Current_Server->{'chans'}}))
	{
	  if (rename_nick($from, $nick, $chan))
	    {
	      irc_add_line($chan, "*: %s is now known as %s", $from, $nick);
	      list_nicks($chan);
	    }
	}
      dcc_change_nick($from, $nick);
    }
}

sub parse_notice
{
  my ($from, $args) = @_;

  if (my ($chan, $mesg) = (${$args} =~ /^(\S+) :?(.*)$/))
    {
      my $pref;
      if (is_channel($chan))
	{
	  my $nref = get_nicks($chan);
	  $pref = get_nickprefix($nref->{$from});
	}

      if (process_ctcp_reply($from, $pref, $chan, \$mesg))
	{
	  irc_add_line($chan, "[%s%s]: %s", $pref, $from, $mesg);
	}
    }
}

sub parse_part
{
  my ($from, $args) = @_;
  my ($chan, $mesg) = (${$args} =~ /^(\S+) :(.*)$/);

  if (del_nick($from, $chan))
    {
      irc_add_line($chan, "<-: Exit %s (%s)", $from, $mesg);

      if (is_me($from))
	{
	  del_channel($chan);
	}
      else
	{
	  list_nicks($chan);
	}
    }
}

sub parse_ping
{
  my $args = shift;

  irc_send("PONG :%s", ${$args});
  irc_add_line('', "Ping? Pong!");
}

sub parse_privmsg
{
  my ($from, $args) = @_;

  if (my ($chan, $mesg) = (${$args} =~ /^(\S+) :(.*)$/))
    {
      my $pref;
      if (is_channel($chan))
	{
	  my $nref = get_nicks($chan);
	  $pref = get_nickprefix($nref->{$from});
	}

      # Handle CTCP messages first
      if (process_ctcp_query($from, $pref, $chan, \$mesg))
	{
	  irc_add_line($chan, "<%s%s>: %s", $pref, $from, $mesg);
	}
    }
}

sub parse_quit
{
  my ($from, $args) = @_;
  my ($mesg) = (${$args} =~ /^:(.*)$/);
  # TODO: handle netsplits

  foreach my $chan (keys(%{$Current_Server->{'chans'}}))
    {
      if (del_nick($from, $chan))
	{
	  irc_add_line($chan, "<=: Exit %s (%s)", $from, $mesg);
	  list_nicks($chan);
	}
    }
}

sub parse_topic
{
  my ($from, $args) = @_;

  if (my ($chan, $topic) = (${$args} =~ /^(\S+) :(.*)$/))
    {
      irc_add_line($chan, "*: %s sets new topic: %s", $from, $topic);
      VIM::DoCommand("call s:SetChannelTopic(\"$chan\", \"$topic\")");
    }
}

sub parse_wallops
{
  my ($from, $args) = @_;

  if (my ($mesg) = (${$args} =~ /^:(.*)$/))
    {
      irc_add_line('', "!%s!: %s", $from, $mesg);
    }
}

sub parse_line
{
  my $line = shift;

  if (my ($from, $comd, $args) = (${$line} =~ /^:(\S+) (\S+) (.*)$/))
    {
      ($from, $From_Server) = ($from =~ /^([^!]+)(?:!(\S+))?$/);

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
	      irc_add_line('', ${$line});
	    }
	}
    }
  else
    {
      if (($comd, $args) = (${$line} =~ /^(\S+) :?(.*)$/))
	{
	  if (0)
	    {
	      vim_printf("comd=%s args=%s", $comd, $args);
	    }
	  $comd = lc($comd);

	  if ($comd eq 'notice')
	    {
	      irc_add_line('', $args);
	    }
	  elsif ($comd && defined(&{'parse_'.$comd}))
	    {
	      &{'parse_'.$comd}(\$args);
	    }
	  else
	    {
	      irc_add_line('', ${$line});
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

  $str =~ s/["\\]/\\$1/g;
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
  # Dunno why perl doesn't have `pwd'
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
  return (-d $dir);
}

sub vim_getvar
{
  my $var = shift;
  return VIM::Eval("exists('$var')") ? scalar(VIM::Eval("$var")) : undef;
}

sub vim_printf
{
  VIM::Msg(sprintf(shift, @_));
}

EOP
endfunction
if s:debug
  call s:PerlIRC()
endif
endif

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions

" vim:ts=8:sts=2:sw=2:fdm=indent:
