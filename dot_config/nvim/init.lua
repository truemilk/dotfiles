vim.loader.enable()

_G.Config = {}

local gr = vim.api.nvim_create_augroup('custom-config', {})
Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end

Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  Config.new_autocmd('PackChanged', '*', f, desc)
end

vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' })

local misc = require('mini.misc')
Config.now = function(f) misc.safely('now', f) end
Config.later = function(f) misc.safely('later', f) end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later

vim.g.mapleader = ' '

vim.o.clipboard   = 'unnamedplus'
vim.o.mouse       = 'a'
vim.o.mousescroll = 'ver:25,hor:6'
vim.o.switchbuf   = 'usetab'
vim.o.undofile    = true

vim.o.shada = "'100,<50,s10,:1000,/100,@100,h"

vim.o.breakindent    = true
vim.o.breakindentopt = 'list:-1'
vim.o.colorcolumn    = '+1'
vim.o.cursorline     = true
vim.o.linebreak      = true
vim.o.list           = true
vim.o.number         = true
vim.o.pumborder      = 'single'
vim.o.pumheight      = 10
vim.o.pummaxwidth    = 100
vim.o.ruler          = false
vim.o.scrolloff      = 10
vim.o.shortmess      = 'CFOSWaco'
vim.o.showmode       = false
vim.o.signcolumn     = 'yes'
vim.o.splitbelow     = true
vim.o.splitkeep      = 'screen'
vim.o.splitright     = true
vim.o.winborder      = 'single'
vim.o.wrap           = false

vim.o.cursorlineopt  = 'screenline,number'

vim.o.fillchars = 'eob: ,fold:╌'
vim.o.listchars = 'extends:…,nbsp:␣,precedes:…,tab:> '

vim.o.foldlevel   = 10
vim.o.foldmethod  = 'indent'
vim.o.foldnestmax = 10
vim.o.foldtext    = ''

vim.o.autoindent    = true
vim.o.expandtab     = true
vim.o.formatoptions = 'rqnl1j'
vim.o.ignorecase    = true
vim.o.incsearch     = true
vim.o.infercase     = true
vim.o.shiftwidth    = 2
vim.o.smartcase     = true
vim.o.smartindent   = true
vim.o.spelloptions  = 'camel'
vim.o.tabstop       = 2
vim.o.virtualedit   = 'block'

vim.o.iskeyword = '@,48-57,_,192-255,-'

vim.o.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]

vim.o.complete        = '.,w,b,kspell'
vim.o.completeopt     = 'menuone,noselect,fuzzy,nosort'
vim.o.completetimeout = 100

local f = function() vim.cmd('setlocal formatoptions-=c formatoptions-=o') end
Config.new_autocmd('FileType', nil, f, "Proper 'formatoptions'")

local diagnostic_opts = {
  signs = { priority = 9999, severity = { min = 'WARN', max = 'ERROR' } },

  underline = { severity = { min = 'HINT', max = 'ERROR' } },

  virtual_lines = false,
  virtual_text = {
    current_line = true,
    severity = { min = 'ERROR', max = 'ERROR' },
  },

  update_in_insert = false,
}

Config.later(function() vim.diagnostic.config(diagnostic_opts) end)

local nmap = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { desc = desc })
end

nmap('[p', '<Cmd>exe "iput! " . v:register<CR>', 'Paste Above')
nmap(']p', '<Cmd>exe "iput "  . v:register<CR>', 'Paste Below')

local toggle_inlay_hints = function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end
nmap('\\I', toggle_inlay_hints, "Toggle 'inlay hints'")

Config.leader_group_clues = {
  { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
  { mode = 'n', keys = '<Leader>e', desc = '+Explore/Edit' },
  { mode = 'n', keys = '<Leader>f', desc = '+Find' },
  { mode = 'n', keys = '<Leader>g', desc = '+Git' },
  { mode = 'n', keys = '<Leader>l', desc = '+Language' },
  { mode = 'n', keys = '<Leader>m', desc = '+Map' },
  { mode = 'n', keys = '<Leader>o', desc = '+Other' },
  { mode = 'n', keys = '<Leader>s', desc = '+Session' },
  { mode = 'n', keys = '<Leader>t', desc = '+Terminal' },
  { mode = 'n', keys = '<Leader>v', desc = '+Visits' },

  { mode = 'x', keys = '<Leader>g', desc = '+Git' },
  { mode = 'x', keys = '<Leader>l', desc = '+Language' },
}

local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })
end
local xmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('x', '<Leader>' .. suffix, rhs, { desc = desc })
end

local new_scratch_buffer = function()
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end

nmap_leader('ba', '<Cmd>b#<CR>',                                 'Alternate')
nmap_leader('bd', '<Cmd>lua MiniBufremove.delete()<CR>',         'Delete')
nmap_leader('bD', '<Cmd>lua MiniBufremove.delete(0, true)<CR>',  'Delete!')
nmap_leader('bs', new_scratch_buffer,                            'Scratch')
nmap_leader('bw', '<Cmd>lua MiniBufremove.wipeout()<CR>',        'Wipeout')
nmap_leader('bW', '<Cmd>lua MiniBufremove.wipeout(0, true)<CR>', 'Wipeout!')

local explore_at_file = '<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>'
local explore_quickfix = function()
  vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and 'cclose' or 'copen')
end
local explore_locations = function()
  vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and 'lclose' or 'lopen')
end

nmap_leader('ed', '<Cmd>lua MiniFiles.open()<CR>',          'Directory')
nmap_leader('ef', explore_at_file,                          'File directory')
nmap_leader('ei', '<Cmd>edit $MYVIMRC<CR>',                 'init.lua')
nmap_leader('en', '<Cmd>lua MiniNotify.show_history()<CR>', 'Notifications')
nmap_leader('eq', explore_quickfix,                         'Quickfix list')
nmap_leader('eQ', explore_locations,                        'Location list')

local pick_added_hunks_buf = '<Cmd>Pick git_hunks path="%" scope="staged"<CR>'
local pick_workspace_symbols_live = '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>'

nmap_leader('f/', '<Cmd>Pick history scope="/"<CR>',            '"/" history')
nmap_leader('f:', '<Cmd>Pick history scope=":"<CR>',            '":" history')
nmap_leader('fa', '<Cmd>Pick git_hunks scope="staged"<CR>',     'Added hunks (all)')
nmap_leader('fA', pick_added_hunks_buf,                         'Added hunks (buf)')
nmap_leader('fb', '<Cmd>Pick buffers<CR>',                      'Buffers')
nmap_leader('fc', '<Cmd>Pick git_commits<CR>',                  'Commits (all)')
nmap_leader('fC', '<Cmd>Pick git_commits path="%"<CR>',         'Commits (buf)')
nmap_leader('fd', '<Cmd>Pick diagnostic scope="all"<CR>',       'Diagnostic workspace')
nmap_leader('fD', '<Cmd>Pick diagnostic scope="current"<CR>',   'Diagnostic buffer')
nmap_leader('ff', '<Cmd>Pick files<CR>',                        'Files')
nmap_leader('fg', '<Cmd>Pick grep_live<CR>',                    'Grep live')
nmap_leader('fG', '<Cmd>Pick grep pattern="<cword>"<CR>',       'Grep current word')
nmap_leader('fh', '<Cmd>Pick help<CR>',                         'Help tags')
nmap_leader('fH', '<Cmd>Pick hl_groups<CR>',                    'Highlight groups')
nmap_leader('fl', '<Cmd>Pick buf_lines scope="all"<CR>',        'Lines (all)')
nmap_leader('fL', '<Cmd>Pick buf_lines scope="current"<CR>',    'Lines (buf)')
nmap_leader('fm', '<Cmd>Pick git_hunks<CR>',                    'Modified hunks (all)')
nmap_leader('fM', '<Cmd>Pick git_hunks path="%"<CR>',           'Modified hunks (buf)')
nmap_leader('fr', '<Cmd>Pick resume<CR>',                       'Resume')
nmap_leader('fR', '<Cmd>Pick lsp scope="references"<CR>',       'References (LSP)')
nmap_leader('fs', pick_workspace_symbols_live,                  'Symbols workspace (live)')
nmap_leader('fS', '<Cmd>Pick lsp scope="document_symbol"<CR>',  'Symbols document')
nmap_leader('fv', '<Cmd>Pick visit_paths cwd=""<CR>',           'Visit paths (all)')
nmap_leader('fV', '<Cmd>Pick visit_paths<CR>',                  'Visit paths (cwd)')

local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. ' --follow -- %'

nmap_leader('ga', '<Cmd>Git diff --cached<CR>',             'Added diff')
nmap_leader('gA', '<Cmd>Git diff --cached -- %<CR>',        'Added diff buffer')
nmap_leader('gc', '<Cmd>Git commit<CR>',                    'Commit')
nmap_leader('gC', '<Cmd>Git commit --amend<CR>',            'Commit amend')
nmap_leader('gd', '<Cmd>Git diff<CR>',                      'Diff')
nmap_leader('gD', '<Cmd>Git diff -- %<CR>',                 'Diff buffer')
nmap_leader('gl', '<Cmd>' .. git_log_cmd .. '<CR>',         'Log')
nmap_leader('gL', '<Cmd>' .. git_log_buf_cmd .. '<CR>',     'Log buffer')
nmap_leader('go', '<Cmd>lua MiniDiff.toggle_overlay()<CR>', 'Toggle overlay')
nmap_leader('gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>',  'Show at cursor')

xmap_leader('gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>', 'Show at selection')

nmap_leader('la', '<Cmd>lua vim.lsp.buf.code_action()<CR>',     'Actions')
nmap_leader('ld', '<Cmd>lua vim.diagnostic.open_float()<CR>',   'Diagnostic popup')
nmap_leader('lf', '<Cmd>lua require("conform").format()<CR>',   'Format')
nmap_leader('li', '<Cmd>lua vim.lsp.buf.implementation()<CR>',  'Implementation')
nmap_leader('lh', '<Cmd>lua vim.lsp.buf.hover()<CR>',           'Hover')
nmap_leader('ll', '<Cmd>lua vim.lsp.codelens.run()<CR>',        'Lens')
nmap_leader('lr', '<Cmd>lua vim.lsp.buf.rename()<CR>',          'Rename')
nmap_leader('lR', '<Cmd>lua vim.lsp.buf.references()<CR>',      'References')
nmap_leader('ls', '<Cmd>lua vim.lsp.buf.definition()<CR>',      'Source definition')
nmap_leader('lt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', 'Type definition')

xmap_leader('lf', '<Cmd>lua require("conform").format()<CR>', 'Format selection')

nmap_leader('mf', '<Cmd>lua MiniMap.toggle_focus()<CR>', 'Focus (toggle)')
nmap_leader('mr', '<Cmd>lua MiniMap.refresh()<CR>',      'Refresh')
nmap_leader('ms', '<Cmd>lua MiniMap.toggle_side()<CR>',  'Side (toggle)')
nmap_leader('mt', '<Cmd>lua MiniMap.toggle()<CR>',       'Toggle')

nmap_leader('or', '<Cmd>lua MiniMisc.resize_window()<CR>', 'Resize to default width')
nmap_leader('ot', '<Cmd>lua MiniTrailspace.trim()<CR>',    'Trim trailspace')
nmap_leader('ou', '<Cmd>lua vim.pack.update()<CR>',        'Update plugins')
nmap_leader('oz', '<Cmd>lua MiniMisc.zoom()<CR>',          'Zoom toggle')

local session_new = 'vim.ui.input({ prompt = "Session name: " }, MiniSessions.write)'

nmap_leader('sd', '<Cmd>lua MiniSessions.select("delete")<CR>', 'Delete')
nmap_leader('sn', '<Cmd>lua ' .. session_new .. '<CR>',         'New')
nmap_leader('sr', '<Cmd>lua MiniSessions.select("read")<CR>',   'Read')
nmap_leader('sR', '<Cmd>lua MiniSessions.restart()<CR>',        'Restart')
nmap_leader('sw', '<Cmd>lua MiniSessions.write()<CR>',          'Write current')

nmap_leader('tT', '<Cmd>horizontal term<CR>', 'Terminal (horizontal)')
nmap_leader('tt', '<Cmd>vertical term<CR>',   'Terminal (vertical)')

local make_pick_core = function(cwd, desc)
  return function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    local local_opts = { cwd = cwd, filter = 'core', sort = sort_latest }
    MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
  end
end

nmap_leader('vc', make_pick_core('',  'Core visits (all)'),       'Core visits (all)')
nmap_leader('vC', make_pick_core(nil, 'Core visits (cwd)'),       'Core visits (cwd)')
nmap_leader('vv', '<Cmd>lua MiniVisits.add_label("core")<CR>',    'Add "core" label')
nmap_leader('vV', '<Cmd>lua MiniVisits.remove_label("core")<CR>', 'Remove "core" label')
nmap_leader('vl', '<Cmd>lua MiniVisits.add_label()<CR>',          'Add label')
nmap_leader('vL', '<Cmd>lua MiniVisits.remove_label()<CR>',       'Remove label')

local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

now(function()
  vim.pack.add({ 'https://github.com/edeneast/nightfox.nvim' })
  vim.cmd('color carbonfox')
end)

now(function()
  require('mini.basics').setup({
    options = { basic = false },
    mappings = {
      windows = true,
      move_with_alt = true,
    },
  })
end)

now(function()
  local ext3_blocklist = { scm = true, txt = true, yml = true }
  local ext4_blocklist = { json = true, yaml = true }
  require('mini.icons').setup({
    use_file_extension = function(ext, _)
      return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
    end,
  })

  later(MiniIcons.mock_nvim_web_devicons)

  later(MiniIcons.tweak_lsp_kind)
end)

now(function() require('mini.notify').setup() end)

now(function() require('mini.sessions').setup() end)

now(function() require('mini.starter').setup() end)

now(function() require('mini.statusline').setup() end)

now(function() require('mini.tabline').setup() end)

now_if_args(function()
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
  local process_items = function(items, base)
    return MiniCompletion.default_process_items(items, base, process_items_opts)
  end
  require('mini.completion').setup({
    lsp_completion = {
      source_func = 'omnifunc',
      auto_setup = false,
      process_items = process_items,
    },
  })

  local on_attach = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
  end
  Config.new_autocmd('LspAttach', nil, on_attach, "Set 'omnifunc'")

  vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

now_if_args(function()
  require('mini.files').setup({ windows = { preview = true } })

  local add_marks = function()
    MiniFiles.set_bookmark('c', vim.fn.stdpath('config'), { desc = 'Config' })
    local vimpack_plugins = vim.fn.stdpath('data') .. '/site/pack/core/opt'
    MiniFiles.set_bookmark('p', vimpack_plugins, { desc = 'Plugins' })
    MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' })
  end
  Config.new_autocmd('User', 'MiniFilesExplorerOpen', add_marks, 'Add bookmarks')
end)

now_if_args(function()
  require('mini.misc').setup()

  MiniMisc.setup_auto_root()

  MiniMisc.setup_restore_cursor()

  MiniMisc.setup_termbg_sync()
end)

later(function() require('mini.extra').setup() end)

later(function()
  local ai = require('mini.ai')
  ai.setup({
    custom_textobjects = {
      B = MiniExtra.gen_ai_spec.buffer(),
      F = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
    },

    search_method = 'cover',
  })
end)

later(function() require('mini.align').setup() end)

later(function() require('mini.bracketed').setup() end)

later(function() require('mini.bufremove').setup() end)

later(function()
  local miniclue = require('mini.clue')
  miniclue.setup({
    clues = {
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    triggers = {
      { mode = { 'n', 'x' }, keys = '<Leader>' },
      { mode =   'n',        keys = '\\' },
      { mode = { 'n', 'x' }, keys = '[' },
      { mode = { 'n', 'x' }, keys = ']' },
      { mode =   'i',        keys = '<C-x>' },
      { mode = { 'n', 'x' }, keys = 'g' },
      { mode = { 'n', 'x' }, keys = "'" },
      { mode = { 'n', 'x' }, keys = '`' },
      { mode = { 'n', 'x' }, keys = '"' },
      { mode = { 'i', 'c' }, keys = '<C-r>' },
      { mode =   'n',        keys = '<C-w>' },
      { mode = { 'n', 'x' }, keys = 's' },
      { mode = { 'n', 'x' }, keys = 'z' },
    },
    window = { delay = 200 },
  })
end)

later(function() require('mini.cmdline').setup() end)

later(function() require('mini.comment').setup() end)

later(function() require('mini.diff').setup() end)

later(function() require('mini.git').setup() end)

later(function()
  local hipatterns = require('mini.hipatterns')
  local hi_words = MiniExtra.gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
      hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
      todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
      note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),

      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

later(function() require('mini.indentscope').setup() end)

later(function() require('mini.input').setup() end)

later(function() require('mini.jump').setup() end)

later(function() require('mini.jump2d').setup() end)

later(function()
  require('mini.keymap').setup()
  MiniKeymap.map_multistep('i', '<Tab>', { 'pmenu_next' })
  MiniKeymap.map_multistep('i', '<S-Tab>', { 'pmenu_prev' })
  MiniKeymap.map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
  MiniKeymap.map_multistep('i', '<BS>', { 'minipairs_bs' })
end)

later(function()
  local map = require('mini.map')
  map.setup({
    symbols = { encode = map.gen_encode_symbols.dot('4x2') },
    integrations = {
      map.gen_integration.builtin_search(),
      map.gen_integration.diff(),
      map.gen_integration.diagnostic(),
    },
  })

  for _, key in ipairs({ 'n', 'N', '*', '#' }) do
    local rhs = key
      .. 'zv'
      .. '<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>'
    vim.keymap.set('n', key, rhs)
  end
end)

later(function() require('mini.move').setup() end)

later(function()
  require('mini.operators').setup()

  vim.keymap.set('n', '(', 'gxiagxila', { remap = true, desc = 'Swap arg left' })
  vim.keymap.set('n', ')', 'gxiagxina', { remap = true, desc = 'Swap arg right' })
end)

later(function()
  require('mini.pairs').setup({ modes = { command = true } })
end)

later(function() require('mini.pick').setup() end)

later(function() require('mini.splitjoin').setup() end)

later(function() require('mini.surround').setup() end)

later(function() require('mini.trailspace').setup() end)

later(function() require('mini.visits').setup() end)

local add = vim.pack.add

now_if_args(function()
  local ts_update = function() vim.cmd('TSUpdate') end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')

  add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  })

  local languages = {
    'lua',
    'vimdoc',
    'markdown',
    'go',
    'rust',
    'terraform',
    'hcl',
    'gomod',
    'gosum',
    'toml',
    'yaml',
    'json',
    'bash',
    'dockerfile',
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev)
    vim.treesitter.start(ev.buf)
    vim.cmd('setlocal foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()')
  end
  Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)

now_if_args(function()
  add({ 'https://github.com/neovim/nvim-lspconfig' })

  vim.lsp.config('lua_ls', {
    on_attach = function(client)
      client.server_capabilities.completionProvider.triggerCharacters =
        { '.', ':', '#', '(' }
    end,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
        hint = { enable = true },
        workspace = {
          ignoreSubmodules = true,
          library = {
            vim.env.VIMRUNTIME,
            vim.fn.stdpath('data') .. '/site/pack/core/opt/mini.nvim',
          },
        },
      },
    },
  })

  vim.lsp.config('gopls', {
    settings = {
      gopls = {
        staticcheck = true,
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  })

  vim.lsp.config('rust_analyzer', {
    settings = {
      ['rust-analyzer'] = { check = { command = 'clippy' } },
    },
  })

  vim.lsp.enable({
    'lua_ls',
    'gopls',
    'rust_analyzer',
    'terraformls',
    'yamlls',
    'taplo',
  })

  vim.lsp.inlay_hint.enable()
end)

later(function()
  add({ 'https://github.com/stevearc/conform.nvim' })

  require('conform').setup({
    default_format_opts = {
      lsp_format = 'fallback',
    },
    formatters_by_ft = {
      go = { 'goimports' },
      rust = { 'rustfmt' },
      terraform = { 'terraform_fmt' },
      ['terraform-vars'] = { 'terraform_fmt' },
    },
  })
end)

Config.new_autocmd('FileType', 'markdown', function(ev)
  vim.cmd('setlocal spell wrap')

  pcall(vim.keymap.del, 'n', 'gO', { buffer = ev.buf })

  vim.b[ev.buf].minisurround_config = {
    custom_surroundings = {
      L = {
        input = { '%[().-()%]%(.-%)' },
        output = function()
          local link = require('mini.surround').user_input('Link: ')
          return { left = '[', right = '](' .. link .. ')' }
        end,
      },
    },
  }
end, 'Markdown settings')
