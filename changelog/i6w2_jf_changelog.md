# Iteration 6 Week 2

## HealthBar

Add invulnerability to HealthBar with an additional option to enable/disable healing when invulnerable. The user can also specify a color for the border that is displayed around the HealthBar when the HealthBar is invulnerable.

![HealthBar with invulnerability enabled](i6w2_Healthbar_invulnerable.png)

## Deployment to Github Pages

We wanted to create an easy way of uploading your game to the web.
**TBD**

### Pitfalls/Issues

When I created the `export.sh` the workflow was unable to execute it. This was caused by Windows, because it doesn't set the correct permissions. Luckily I found this: [GitHub Actions: Fixing the 'Permission Denied' error for shell scripts](https://dev.to/aileenr/github-actions-fixing-the-permission-denied-error-for-shell-scripts-4gbl).

The command `git update-index --chmod=+x export.sh` has to be executed locally in order to allow the script to be executed in the workflow.
