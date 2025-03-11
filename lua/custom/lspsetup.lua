local lspconfig = require 'lspconfig'

lspconfig.ols.setup {
  init_options = {
    checker_args = '-strict-style',
    collection = {
      { name = 'shared', path = vim.fn.expand '$ODIN_ROOT' },
    },
  },
}

local cfg = {
  configurations = {
    odin = {
      {
        name = 'Debugger',
        type = 'lldb',
        request = 'launch',
        cwd = '${workspaceFolder}',
        program = function()
          local out_drop = vim.fn.system { 'mkdir', '-p', 'build' }
          local out = vim.fn.system { 'odin', 'build', '.', '-out:build/raw', '-debug' }
          if vim.v.shell_error ~= 0 then
            vim.notify(out, vim.log.levels.ERROR)
            return nil
          end
          return 'build/raw'
        end,
        stopOnEntry = false,
        args = {},
      },
    },
  },
}

require('dap-lldb').setup(cfg)
--[[
local debugger = vim.fn.exepath 'lldb'
if debugger ~= '' then
  dap.adapters.lldb = {
    type = 'executable',
    command = debugger,
  }
  dap.configurations.lldb = {
    {
      type = 'lldb',
      name = 'debug',
      task = 'build/raw',
      request = 'launch',
      program = '${workspaceFolder}/build/raw',
      exitAfterTaskReturns = false,
      debugAutoInterpretAllModules = false,
    },
  }
end
--]]
