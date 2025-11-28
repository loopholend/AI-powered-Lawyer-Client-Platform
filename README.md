# AI-powered-Lawyer-Client-Platform

Java/NetBeans web application for lawyer-client platform.

How to upload this project to GitHub

1. Create a GitHub repository (via website or `gh`):
   - Website: New repository -> name it `AI-powered-Lawyer-Client-Platform`.
   - CLI: `gh repo create AI-powered-Lawyer-Client-Platform --public` (if `gh` installed).

2. From project root, run (PowerShell):
```
cd "c:\Users\Pranjal Pal\Documents\NetBeansProjects\WebApplication4"
git init
git add .
git commit -m "Initial commit"
# If using gh to create+push the repo:
gh repo create AI-powered-Lawyer-Client-Platform --public --source=. --remote=origin --push
# Or, if you created the repo via website, add remote and push:
git remote add origin https://github.com/<your-username>/AI-powered-Lawyer-Client-Platform.git
git branch -M main
git push -u origin main
```

3. Verify on GitHub and enable settings (branch protection, README, licence) as desired.

Replace `<your-username>` with your GitHub username where needed.
