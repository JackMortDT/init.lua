local home_path = os.getenv("HOME")
print(home_path)

require("chatgpt").setup({
  api_host_cmd = "echo -n https://prod-global-openai-client.ist.nubank.world",
  api_key_cmd = "cat " .. home_path .. "/dev/nu/.nu/tokens/ist/prod/access",
  extra_curl_params = {
    "--cert",
    home_path .. "/dev/nu/.nu/certificates/ist/prod/cert.pem",
    "--key",
    home_path .. "/dev/nu/.nu/certificates/ist/prod/key.pem",
  },
})
