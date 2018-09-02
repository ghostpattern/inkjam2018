using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class DutchSway : MonoBehaviour
{

	[ReadOnly] public CinemachineVirtualCamera cinemachineVirtualCamera;

	// Use this for initialization
	private void Reset()
	{
		cinemachineVirtualCamera = GetComponent<CinemachineVirtualCamera>();
	}

	public float speed = 1;
	private float time;
	public float dutch = 1;
	
	// Update is called once per frame
	void Update ()
	{
		time += Time.deltaTime * speed;
		cinemachineVirtualCamera.m_Lens.Dutch = Mathf.Sin(time) * dutch;
	}
}
