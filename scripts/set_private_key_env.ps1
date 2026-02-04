$file = 'key_private.pem'
if (-Not (Test-Path $file)) {
  Write-Error "Private key file '$file' not found in current directory."
  exit 1
}

# Set TF_VAR_private_key from the local pem file for this PowerShell session
$env:TF_VAR_private_key = Get-Content -Raw -Path $file
Write-Host "TF_VAR_private_key set from $file (session only). Do NOT commit the key."

# To persist for current user session, you may add the Get-Content command to your profile,
# but DO NOT commit private keys to the repository.
