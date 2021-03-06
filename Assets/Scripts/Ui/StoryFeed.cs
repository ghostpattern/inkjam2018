﻿using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public enum StoryFeedKey
{
    Left,
    Right
}

public class StoryFeed : MonoBehaviour
{
    public GameObject LineParent;
    [UnityEngine.Serialization.FormerlySerializedAs("LinePrefab")]
    public GameObject LineLeftPrefab;
    public GameObject LineRightPrefab;
    public GameObject OptionPrefab;
    public Text Title;
    public float MinimumLineDistance;
    public float MinimumLineBuffer;
    public float MinimumOptionBuffer;

    public static KeyCode[][] SelectionKeys =
    {
        new [] {KeyCode.A, KeyCode.J},
        new [] {KeyCode.S, KeyCode.K},
        new [] {KeyCode.D, KeyCode.L}
    };

    public static KeyCode[] SkipKeys =
    {
        KeyCode.Z, KeyCode.M
    };

    private readonly float _initialLineY = 0.0f;
    private float _currLineY = 0.0f;
    private bool _dragMode = false;
    private Vector3 _lastMousePos;

    private readonly List<GameObject> _currentOptionLines = new List<GameObject>();

    public bool DisplayingLine
    {
        get { return _currPerCharacterWriter != null && _currPerCharacterWriter.Animating; }
    }

    private PerCharacterWriter _currPerCharacterWriter;
    public float TitleFadeInTime = 1.0f;
    public float TitleShowTime = 1.0f;
    public float TitleFadeOutTime = 1.0f;

    public void Awake()
    {
        if (LineParent == null)
        {
            LineParent = new GameObject("LineParent");
            LineParent.transform.SetParent(transform, false);
        }

        Title.color = Color.clear;
    }

    public void Update()
    {
        UpdateTextScrolling();

        if(_currPerCharacterWriter != null)
        {
            _currPerCharacterWriter.PerCharacterSpeed = 1.0f;
        }
    }

    public void Clear()
    {
        for(int i = 0; i < LineParent.transform.childCount; i++)
        {
            Destroy(LineParent.transform.GetChild(i).gameObject);
        }

        _currLineY = _initialLineY;
        LineParent.GetComponent<RectTransform>().anchoredPosition = Vector2.zero;
    }

    public enum Side
    {
        Left,
        Right
    }

    public void DisplayLine(string displayText, Side side)
    {
        displayText = displayText.Trim(new char[] { '\n', '\r' });

        GameObject linePrefab = (side == Side.Left ? LineLeftPrefab : LineRightPrefab);
        GameObject line = Instantiate(linePrefab, LineParent.transform, false);

        if (LineParent.transform.childCount > 1)
            _currLineY -= MinimumLineBuffer;

        var position = line.GetComponent<RectTransform>().anchoredPosition;
        position.y = _currLineY;
        line.GetComponent<RectTransform>().anchoredPosition = position;

        Text text = line.GetComponent<Text>();
        text.text = displayText;

        ContentSizeFitter contentSizeFitter = line.GetComponent<ContentSizeFitter>();
        contentSizeFitter.SetLayoutVertical();

        _currLineY -= Mathf.Max(MinimumLineDistance, line.GetComponent<RectTransform>().rect.height);

        var feedPosition = LineParent.GetComponent<RectTransform>().anchoredPosition;
        feedPosition.y = Mathf.Abs(_currLineY);
        LineParent.GetComponent<RectTransform>().anchoredPosition = feedPosition;

        _currPerCharacterWriter = line.GetComponent<PerCharacterWriter>();
        if(side == Side.Right)
        {
            _currPerCharacterWriter.Instant = true;
        }
    }

    public int DisplayOptionLine(string optionText, Action action)
    {
        optionText = optionText.Trim(new char[] { '\n', '\r' });

        int optionNumber = _currentOptionLines.Count;
        KeyCode inputKey = KeyCode.None;
        /*
        string inputName = "";
        if (optionNumber < SelectionKeys.Length)
        {
            if ((int)CharacterKey < SelectionKeys[optionNumber].Length)
            {
                inputKey = SelectionKeys[optionNumber][(int)CharacterKey];
                if (inputKey != KeyCode.None)
                {
                    inputName = "(" + inputKey.ToString() + ") ";
                }
            }
        }
        */

        GameObject line = Instantiate(OptionPrefab, LineParent.transform, false);

        if (LineParent.transform.childCount > 1)
        {
            if (_currentOptionLines.Count == 0)
                _currLineY -= MinimumLineBuffer * 2f;
            else
                _currLineY -= MinimumOptionBuffer;
        }

        var position = line.GetComponent<RectTransform>().anchoredPosition;
        position.y = _currLineY;
        line.GetComponent<RectTransform>().anchoredPosition = position;

        Text text = line.GetComponent<Text>();
        text.text = /*inputName + */optionText + "  ●";

        ContentSizeFitter contentSizeFitter = line.GetComponent<ContentSizeFitter>();
        contentSizeFitter.SetLayoutVertical();

        _currLineY -= Mathf.Max(MinimumLineDistance, line.GetComponent<RectTransform>().rect.height);

        var feedPosition = LineParent.GetComponent<RectTransform>().anchoredPosition;
        feedPosition.y = Mathf.Abs(_currLineY);
        LineParent.GetComponent<RectTransform>().anchoredPosition = feedPosition;

        Button button = line.GetComponent<Button>();
        button.onClick.AddListener(() =>
        {
            SelectOption(button.gameObject);
            action();
            //GetComponent<AudioSource>().Play();
        });

        KeyboardSelection keyboardSelection = line.GetComponent<KeyboardSelection>();
        keyboardSelection.InputKey = inputKey;

        _currentOptionLines.Add(line);

        return line.GetInstanceID();
    }

    public void RemoveOptionLine(int optionId)
    {
        GameObject optionToRemove = _currentOptionLines.Find(line => line.GetInstanceID() == optionId);
        if(optionToRemove != null)
        {
            _currentOptionLines.Remove(optionToRemove);

            Destroy(optionToRemove.GetComponent<Button>());
            optionToRemove.GetComponent<Text>().color = Color.black;
        }
    }

    public void UpdateTextScrolling()
    {
        bool moveFeed = false;
        float moveAmount = 0.0f;

        RectTransform rectTransform = transform.GetComponent<RectTransform>();

        Vector3 mousePos = Vector3.zero;
        Vector3 mousePosLocal = Vector3.zero;
        bool mouseInRect = false;

        // Get the mouse information
        if (Input.mousePresent)
        {
            mousePos = Input.mousePosition;
        }
        else if (Input.touchCount > 0)
        {
            mousePos = Input.touches[0].position;
        }
        else
        {
            mousePos.x = Mathf.NegativeInfinity;
            mousePos.y = Mathf.NegativeInfinity;
        }

        // Get the mouse information, but in space local to the story feed
        // and check whether the mouse is inside story feeds rect
        mousePosLocal = rectTransform.InverseTransformPoint(mousePos);
        mouseInRect = rectTransform.rect.Contains(mousePosLocal);

        // Check for mouse scrolling and store the scroll amount
        if (mouseInRect)
        {
            if (Mathf.Abs(Input.mouseScrollDelta.y) > Mathf.Epsilon)
            {
                moveFeed = true;
                moveAmount += Input.mouseScrollDelta.y * -50.0f;
            }
        }

        // Check for dragging and store the drag amount
        if (_dragMode)
        {
            if (Input.GetMouseButton(0))
            {
                Vector3 dragAmount = mousePosLocal - _lastMousePos;
                _lastMousePos = mousePosLocal;

                moveFeed = true;
                moveAmount += dragAmount.y;
            }
            else
            {
                _dragMode = false;
            }
        }
        else
        {
            if (mouseInRect && Input.GetMouseButtonDown(0))
            {
                _lastMousePos = mousePosLocal;
                _dragMode = true;
            }
        }

        // If we have decided that the box should move, move the box
        if (moveFeed && Mathf.Abs(_currLineY) > rectTransform.rect.height)
        {
            var feedPosition = LineParent.GetComponent<RectTransform>().anchoredPosition;
            feedPosition.y += moveAmount;
            feedPosition.y = Mathf.Max(rectTransform.rect.height, Mathf.Min(Mathf.Abs(_currLineY), feedPosition.y));
            LineParent.GetComponent<RectTransform>().anchoredPosition = feedPosition;
        }
    }

    public void SelectOption(GameObject option)
    {
        foreach(var currentOptionLine in _currentOptionLines)
        {
            Destroy(currentOptionLine.GetComponent<Button>());

            if (GameObject.Equals(currentOptionLine, option))
            {
                currentOptionLine.GetComponent<Text>().color = Color.black;
            }
            else
            {
                currentOptionLine.GetComponent<Text>().color = new Color(0.75f, 0.75f, 0.75f);
            }
        }

        _currentOptionLines.Clear();
    }
}
