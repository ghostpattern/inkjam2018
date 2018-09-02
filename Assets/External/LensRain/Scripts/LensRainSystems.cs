using UnityEngine;

public class LensRainSystems : MonoBehaviour 
{
	public ParticleSystem[] m_Systems; // Particle system array

	// Set parameters from the effect on the particle systems
	public void SetParameters(LensRain input)
	{
		foreach (ParticleSystem pS in m_Systems)
		{
			var main = pS.main; // Get main module
			main.startSize = new ParticleSystem.MinMaxCurve(input.size, input.size * 0.5f); // Set size
			var emission = pS.emission; // Get emission module
			emission.rateOverTime = new ParticleSystem.MinMaxCurve(input.amount * 2f); // Set amount
			var subEmitters = pS.subEmitters; // Get sub emitters
			bool hasSubmitters = subEmitters.subEmittersCount > 0; // Does the system have subemitters?
			if(hasSubmitters) // If the system has subemitters
			{
				ParticleSystem childSystem = subEmitters.GetSubEmitterSystem(0); // Get sub emitter
				if(childSystem)
				{
					var forceOverLifeTime = childSystem.forceOverLifetime; // Get force over lifetime
					forceOverLifeTime.x = new ParticleSystem.MinMaxCurve(input.direction, 0); // Set direction
				}
			}
		}
	}
}
