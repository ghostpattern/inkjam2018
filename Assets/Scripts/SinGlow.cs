using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class SinGlow : MonoBehaviour {

	public float speed = 1;

	private float time;
	public float min = 0;
	public float max = 1;


	private Material mat;
	// Use this for initialization
	void Start ()
	{
		Renderer renderer = GetComponent<Renderer>();
		mat = renderer.sharedMaterial;
		mat = new Material(mat);
		renderer.sharedMaterial = mat;
	}
	
	// Update is called once per frame
	void Update ()
	{
		float v = min + (Mathf.Sin(time)+1)/2f * (max-min);
		mat.color = new Color(v,v,v);
		time += Time.deltaTime * speed;
	}
}
