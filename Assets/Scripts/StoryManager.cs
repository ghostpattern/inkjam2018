using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Ink.Runtime;

public class StoryManager : MonoBehaviour
{
    public TextAsset StoryAsset;
    private Story _inkStory;
    private StoryFeed _storyFeed;

    // Use this for initialization
    void Start()
    {
        _inkStory = new Story(StoryAsset.text);
        _storyFeed = GetComponent<StoryFeed>();
        StartCoroutine(ProcessStory());
    }

    private IEnumerator ProcessStory()
    {
        while(_inkStory.canContinue)
        {
            string inkLine = _inkStory.Continue();

            if(!ParseAction(inkLine))
            {
                float delayTime;
                inkLine = ParseDisplayTime(inkLine, out delayTime);

                delayTime = delayTime < 0.0f ? 2.0f : delayTime;

                _storyFeed.DisplayLine(inkLine);

                while(_storyFeed.DisplayingLine)
                {
                    yield return null;
                }

                float timer = 0.0f;
                while(timer < delayTime)
                {
                    timer += Time.deltaTime;

                    yield return null;

                    if(Input.GetMouseButtonDown(0))
                    {
                        break;
                    }
                }
            }

            if(_inkStory.canContinue == false)
            {
                DisplayCurrentInkChoices();

                while(_inkStory.canContinue == false && _inkStory.currentChoices.Count > 0)
                {
                    yield return null;
                }
            }
        }
    }
    private void DisplayCurrentInkChoices()
    {
        for(int i = 0; i < _inkStory.currentChoices.Count; i++)
        {
            var choiceInstance = _inkStory.currentChoices[i];
            int currChoiceIndex = i;
            _storyFeed.DisplayOptionLine(choiceInstance.text, () =>
            {
                _storyFeed.ClearOptions();
                _inkStory.ChooseChoiceIndex(currChoiceIndex);
            });
        }
    }

    private string ParseDisplayTime(string line, out float displayTime)
    {
        displayTime = -1.0f;

        if(line.EndsWith("]\n"))
        {
            string[] valueAndTime = line.Split('[');
            if(valueAndTime.Length > 1)
            {
                line = valueAndTime[0].Trim(' ', '\t');
                if(float.TryParse(valueAndTime[1].Substring(0, valueAndTime[1].IndexOf("s", StringComparison.Ordinal)), out displayTime) == false)
                {
                    displayTime = -1.0f;
                }
            }
        }

        return line;
    }

    private bool ParseAction(string value)
    {
        value = value.Trim('.', '\n', ' ');

        string[] colonSplit = value.Split(':');

        if(string.Compare(colonSplit[0], "audio", StringComparison.OrdinalIgnoreCase) == 0)
        {
            float delayTime = 0.0f;
            if(colonSplit.Length > 2)
            {
                float.TryParse(colonSplit[2], out delayTime);
            }
            Debug.LogFormat("Playing audio: {0} with delay of {1}", colonSplit[1], delayTime);
            InkAudioLink[] audioLinks = FindObjectsOfType<InkAudioLink>();
            foreach(InkAudioLink inkAudioTrigger in audioLinks)
            {
                if(string.Equals(colonSplit[1], inkAudioTrigger.Key))
                {

                    if(delayTime > 0)
                    {
                        inkAudioTrigger.AudioSource.PlayDelayed(delayTime);
                    }
                    else
                    {
                        inkAudioTrigger.AudioSource.Play();
                    }
                }
            }

            return true;
        }
        else if(string.Compare(colonSplit[0], "visual", StringComparison.OrdinalIgnoreCase) == 0)
        {
            
        }

        return false;
    }

}
