# LaTeX

## Install

Using VS Code in WSL 2:

1. Install the `LaTeX Workshop` extension
2. Update your VS Code configuration (`Ctrl` + `shift` + `P`, and search for `Preferences: Open User Settings (JSON)`) with the following lines:

```sh
"latex-workshop.docker.enabled": true,
"latex-workshop.docker.image.latex": "tianon/latex",
"latex-workshop.view.pdf.viewer": "browser",
```
