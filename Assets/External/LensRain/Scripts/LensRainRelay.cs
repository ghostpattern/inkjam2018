using UnityEngine;

[ExecuteInEditMode]
public class LensRainRelay : MonoBehaviour
{
	public LensRainSystems lensRainSystem;
	public Vector2 textureSizeOverride;
	
	//Singleton
	private static LensRainRelay m_Instance;
	public static LensRainRelay Instance
	{
		get 
		{
			if(m_Instance == null) 
				m_Instance = FindObjectOfType<LensRainRelay>();
			return m_Instance; 
		}
	}
	

	[HideInInspector] public RenderTexture m_LensRainTexture; // Target texture for rain camera
	[HideInInspector] public LensRainSystems m_LensRainSystems; // Reference to systems

	// Called when component is added
	void Reset()
	{
		m_LensRainTexture = GetRainTexture(); // Get rain texture
		m_LensRainSystems = GetRainSystems(); // Get rain system
		m_LensRainSystems.GetComponent<Camera>().targetTexture = m_LensRainTexture; // Set camera target
	}

	// Get rain texture
	RenderTexture GetRainTexture()
	{
		if(m_LensRainTexture) // If texture exists
			return m_LensRainTexture; // Return
		// If texture doesnt exist
		var size = textureSizeOverride == Vector2.zero ? new Vector2(Screen.width, Screen.height) : textureSizeOverride;
		var tex = new RenderTexture(Mathf.RoundToInt(size.x), Mathf.RoundToInt(size.y), 16, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear) {name = "RainTexture"}; // Create new RT
		// Set name
		return tex; // Return
	}

	// Get rain systems
	LensRainSystems GetRainSystems()
	{

		if (lensRainSystem != null)
			return lensRainSystem;
		
		Transform systemTransform = transform.Find("RainSystems"); // Find current systems
		if(systemTransform) // If systems exist
			return systemTransform.GetComponent<LensRainSystems>(); // Return

		// If systems don't exist
		var prefab = (GameObject)Resources.Load("RainSystems"); // Load prefab
		var instance = Instantiate(prefab, transform.position, transform.rotation, transform); // Instantiate
		instance.name = "RainSystems"; // Set name
		return instance.GetComponent<LensRainSystems>(); // Return
	}

	// Relay parameters from Rain.cs to RainSystems
	public void RelayParameters(LensRain input)
	{
		if(m_LensRainSystems) // If rain systems are active
			m_LensRainSystems.SetParameters(input); // Relay
	}
}
