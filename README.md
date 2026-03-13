# flutter_app_template_cli

Generate a Flutter monorepo workspace with `apps/` and `packages/` plus a ready-to-run app template.

## Usage

```bash
dart run flutter_app_template_cli create my_workspace \
  --app-name my_app \
  --org com.example \
  --description "My Flutter app"
```

## What it creates

```
my_workspace/
  apps/
    my_app/
  packages/
  tools/
```

After creation, run:

```bash
cd my_workspace
./tools/bootstrap.sh
```
