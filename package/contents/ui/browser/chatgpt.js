const getPromptInput = () => document.querySelector('#prompt-textarea');

const tryToFocusPromptInput = () => {
  const promptInput = getPromptInput();
  if (!promptInput) {
    console.debug('(tryToFocusPromptInput): No prompt input found');

    return;
  }

  promptInput.focus();
}

const onUrlChanged = (callback) => {
  let previousUrl = '';
  const observer = new MutationObserver(() => {
    if (location.href !== previousUrl) {
      previousUrl = location.href;

      callback({ url: location.href });
    }
  });

  observer.observe(document, {
    childList: true,
    subtree: true,
  })
}

const onPromptInputKeydown = (event) => {
  const promptInput = event.target;

  if (promptInput.value.trim().length < 0) {
    return
  }

  if (event.ctrlKey && event.key === 'Enter') {
    const sendButton = document.querySelector('[data-testid="send-button"]');
    if (!sendButton) {
      return;
    }

    sendButton.click();
  }
}

const isExternalLink = (url) => {
  return !url.includes('openai.com');
}

const isDarkMode = () => document.documentElement.classList.contains('dark');

const removeBlackPlaceholderInPromptInput = () => {
  const promptInput = getPromptInput();

  const placeholderGray = 'placeholder-gray-500'
  const placeholderBlack = 'placeholder-black/50'

  if (!promptInput?.classList.contains(placeholderGray)) {
    promptInput.classList.add(placeholderGray);
    promptInput.classList.remove(placeholderBlack);
  }
}

// `WebEngineView` show the placeholder text in black color when dark mode is enabled.
// This is a workaround to fix this issue. We can remove this once the issue is fixed.
const fixDarkModeStyles = () => {
  if (!isDarkMode() || !getPromptInput()) {
    return;
  }

  removeBlackPlaceholderInPromptInput();

  const observer = new MutationObserver((changes) => {
    for (const change of changes) {
      // If the class attribute is changed, we need to fix the dark mode styles again.
      if (change.type === 'attributes' && change.attributeName === 'class') {
        removeBlackPlaceholderInPromptInput();

        observer.disconnect();
      }
    }
  });

  observer.observe(getPromptInput(), {
    attributes: true,
    attributeFilter: ['class'],
  })
}

const main = () => {
  onUrlChanged(() => {
    const promptInput = getPromptInput();
    if (!promptInput) {
      return;
    }

    fixDarkModeStyles()

    promptInput.removeEventListener('keydown', onPromptInputKeydown);

    promptInput.addEventListener('keydown', onPromptInputKeydown);
  });

  document.addEventListener('click', (event) => {
    if (event.target.nodeName === 'A') {
      if (isExternalLink(event.target.href)) {
        event.preventDefault();
        window.location.href = event.target.href;
      }
    }
  });
}

main();
