using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InkAudioTrigger : MonoBehaviour
{
    public string Key;
    [SerializeField]
    private AudioSource _audioSource;
    public AudioSource AudioSource { get { return _audioSource; } }
	// Use this for initialization
	void Start ()
	{
        if(_audioSource == null)
	        _audioSource = GetComponent<AudioSource>();
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
