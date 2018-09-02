using System;
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

    private readonly Vector3 _initialLinePosition = new Vector3(16.0f, -16.0f, 0.0f);
    private float _currLineY = -16.0f;
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

        _currLineY = _initialLinePosition.y;
        LineParent.transform.localPosition = Vector3.zero;
    }

    public enum Side
    {
        Left,
        Right
    }

    public void DisplayLine(string displayText, Side side)
    {
        GameObject line = Instantiate(side == Side.Left ? LineLeftPrefab : LineRightPrefab, LineParent.transform, false);

        var position = line.transform.localPosition;
        position.y = _currLineY;
        line.transform.localPosition = position;

        Text text = line.GetComponent<Text>();
        text.text = displayText;

        ContentSizeFitter contentSizeFitter = line.GetComponent<ContentSizeFitter>();
        contentSizeFitter.SetLayoutVertical();

        _currLineY -= Mathf.Max(MinimumLineDistance, line.GetComponent<RectTransform>().rect.height + MinimumLineBuffer);

        RectTransform rectTransform = transform.GetComponent<RectTransform>();

        if(_currLineY < (LineParent.transform.localPosition.y - rectTransform.rect.height))
        {
            Vector3 feedPosition = LineParent.transform.localPosition;
            feedPosition.y = Mathf.Abs(_currLineY) - rectTransform.rect.height;
            LineParent.transform.localPosition = feedPosition;
        }

        _currPerCharacterWriter = line.GetComponent<PerCharacterWriter>();
    }

    public int DisplayOptionLine(string optionText, Action action)
    {
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

        var position = line.transform.localPosition;
        position.y = _currLineY;
        line.transform.localPosition = position;

        Text text = line.GetComponent<Text>();
        text.text = /*inputName + */optionText + "  ●";

        ContentSizeFitter contentSizeFitter = line.GetComponent<ContentSizeFitter>();
        contentSizeFitter.SetLayoutVertical();

        _currLineY -= Mathf.Max(MinimumLineDistance, line.GetComponent<RectTransform>().rect.height + MinimumLineBuffer);

        RectTransform rectTransform = transform.GetComponent<RectTransform>();

        if(_currLineY < (LineParent.transform.localPosition.y - rectTransform.rect.height))
        {
            Vector3 feedPosition = LineParent.transform.localPosition;
            feedPosition.y = Mathf.Abs(_currLineY) - rectTransform.rect.height;
            LineParent.transform.localPosition = feedPosition;
        }

        Button button = line.GetComponent<Button>();
        button.onClick.AddListener(() =>
        {
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
            Destroy(optionToRemove);
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
        if (moveFeed)
        {
            float yMin = Mathf.Abs(_currLineY) - rectTransform.rect.height;

            Vector3 feedPosition = LineParent.transform.localPosition;
            feedPosition.y += moveAmount;
            feedPosition.y = Mathf.Max(0.0f, Mathf.Min(yMin, feedPosition.y));
            LineParent.transform.localPosition = feedPosition;
        }
    }

    public void ClearOptions()
    {
        foreach(var currentOptionLine in _currentOptionLines)
        {
            Destroy(currentOptionLine);
        }

        _currentOptionLines.Clear();
    }
}
