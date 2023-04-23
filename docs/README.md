# Documentation

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [LaTeX](#latex)
  - [Install](#install)
- [Usage](#usage)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# LaTeX

## Install

`Docker` needs to be installed and running in your WSL 2 distro. Otherwise, using VS Code in WSL 2:

1. Install the `LaTeX Workshop` extension
2. Update your VS Code configuration (`Ctrl` + `shift` + `P`, and search for `Preferences: Open User Settings (JSON)`) with the following lines:

```sh
"latex-workshop.docker.enabled": true,
"latex-workshop.docker.image.latex": "tianon/latex",
"latex-workshop.view.pdf.viewer": "browser",
```

# Usage

Saving a `.tex` file will result in the LaTeX builder running
