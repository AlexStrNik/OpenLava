# Lava Web Example

This is an example React application that demonstrates how to use the LavaWeb renderer to display Lava animations in a web browser.

## Setup

This project uses pnpm as the package manager. To get started, run:

```bash
pnpm install
pnpm dev
```

## Project Structure

- `src/components/LavaAnimation.tsx`: A React component that wraps the LavaRenderer
- `src/App.tsx`: Main application component that uses the LavaAnimation component
- `public/animations/`: Directory containing example Lava animations

## Usage

The LavaAnimation component can be used as follows:

```tsx
import LavaAnimation from "./components/LavaAnimation";

function App() {
  return (
    <div>
      <LavaAnimation
        assetPath="/animations/m13HomepageExperiencesTabInitialAnimationLavaAssets"
        width={400}
        height={400}
      />
    </div>
  );
}
```

## Props

- `assetPath`: Path to the Lava animation assets directory (required)
- `width`: Width of the animation canvas (default: 300)
- `height`: Height of the animation canvas (default: 300)

## Animation Format

The animation directory should contain:

- `manifest.json`: Animation metadata and frame information
- Image files referenced in the manifest

See the example in `public/animations/m13HomepageExperiencesTabInitialAnimationLavaAssets/` for the expected structure.
