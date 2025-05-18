import LavaAnimation from "./components/LavaAnimation";

function App() {
  return (
    <>
      <h1>Lava Animation Example</h1>

      <div className="animation-wrapper">
        <LavaAnimation
          assetPath={
            "/animations/m13HomepageExperiencesTabInitialAnimationLavaAssets"
          }
          width={180}
          height={162}
        />
      </div>
    </>
  );
}

export default App;
