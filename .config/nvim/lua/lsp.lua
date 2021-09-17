local lsp = require "lspconfig"

function on_attach(client, bufnr)
    require "lsp_signature".on_attach()
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

lsp.rust_analyzer.setup{ on_attach = on_attach, capabilities=capabilities }
lsp.gopls.setup{ on_attach = on_attach, capabilities=capabilities }
lsp.pyright.setup{ on_attach = on_attach, capabilities=capabilities }
lsp.omnisharp.setup{ on_attach = on_attach, capabilitie=capabilities, cmd = {
    "/usr/bin/omnisharp",
    "--languageserver",
    "--hostPID",
    tostring(vim.fn.getpid()),
}}

