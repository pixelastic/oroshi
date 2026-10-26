import { __, documentRead } from '../documentRead.js';

// Helper to build a Google Docs paragraph element
/**
 * Build a Google Docs text run element
 * @param {string} content - Text content
 * @param {object} style - Text style overrides
 * @returns {object} Text run element
 */
function textRun(content, style = {}) {
  return { textRun: { content, textStyle: style } };
}
/**
 * Build a Google Docs paragraph element
 * @param {object[]} elements - Paragraph elements
 * @param {string} styleType - Named style type
 * @param {object|null} bullet - Bullet configuration
 * @returns {object} Paragraph element
 */
function paragraph(elements, styleType = 'NORMAL_TEXT', bullet = null) {
  const para = {
    paragraph: {
      elements,
      paragraphStyle: { namedStyleType: styleType },
    },
  };
  if (bullet) {
    para.paragraph.bullet = bullet;
  }
  return para;
}

/**
 * Build a tab object matching Google Docs API tab structure
 * @param {string} tabId - Tab identifier
 * @param {object} body - Tab body content
 * @param {object} extras - Extra tab properties (inlineObjects, lists, childTabs)
 * @returns {object} Tab object
 */
function tab(tabId, body, extras = {}) {
  const { inlineObjects, lists, childTabs, title } = {
    inlineObjects: {},
    lists: {},
    childTabs: [],
    title: tabId,
    ...extras,
  };
  return {
    tabProperties: { tabId, title },
    documentTab: { body, inlineObjects, lists },
    childTabs,
  };
}

describe('findTab', () => {
  const tabs = [
    tab('t.first', { content: [] }),
    tab(
      't.second',
      { content: [] },
      {
        childTabs: [tab('t.nested', { content: [] })],
      },
    ),
  ];

  it.each([
    {
      title: 'finds tab in flat list by tabId',
      input: 't.first',
      expected: 't.first',
    },
    {
      title: 'finds tab nested in childTabs',
      input: 't.nested',
      expected: 't.nested',
    },
  ])('$title', ({ input, expected }) => {
    const actual = __.findTab(tabs, input);
    expect(actual).toHaveProperty('tabProperties.tabId', expected);
  });

  it('throws when tabId not found in document', () => {
    let actual = null;
    try {
      __.findTab(tabs, 't.nonexistent');
    } catch (error) {
      actual = error;
    }
    expect(actual).toHaveProperty('code', 'GDOC_TAB_NOT_FOUND');
    expect(actual).toHaveProperty(
      'message',
      'Tab "t.nonexistent" not found in document',
    );
  });
});

describe('formatTab', () => {
  it('reshapes tab documentTab into legacy doc shape with body, inlineObjects, lists, title', () => {
    const input = tab(
      't.abc',
      {
        content: [paragraph([textRun('Hello\n')], 'HEADING_1')],
      },
      {
        inlineObjects: { img1: { data: 'mock' } },
        lists: { list1: { data: 'mock' } },
      },
    );
    const doc = { title: 'My Doc' };

    const actual = __.formatTab(input, doc);
    expect(actual).toEqual({
      title: 'My Doc',
      body: { content: [paragraph([textRun('Hello\n')], 'HEADING_1')] },
      inlineObjects: { img1: { data: 'mock' } },
      lists: { list1: { data: 'mock' } },
    });
  });
});

describe('documentRead', () => {
  const tabBody = {
    content: [paragraph([textRun('Hello\n')], 'HEADING_1')],
  };
  const secondTabBody = {
    content: [paragraph([textRun('Second\n')], 'HEADING_1')],
  };

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      title: 'My Document',
      tabs: [tab('t.first', tabBody), tab('t.second', secondTabBody)],
    });
    vi.spyOn(__, 'formatDocument').mockImplementation((input) => input);
  });

  it('fetches the document with its tabs', async () => {
    await documentRead({
      documentId: 'https://docs.google.com/document/d/abc123/edit',
    });

    expect(__.callApi).toHaveBeenCalledWith(
      'documents/abc123?includeTabsContent=true',
    );
  });

  it('without tab, reads the first tab', async () => {
    const actual = await documentRead({ documentId: 'abc123' });

    expect(actual).toHaveProperty('markdown', '# Hello\n\n');
    expect(actual).toHaveProperty('title', 'My Document');
    expect(actual).toHaveProperty('documentId', 'abc123');
  });

  it('with a tab in the URL, reads that tab', async () => {
    const actual = await documentRead({
      documentId: 'https://docs.google.com/document/d/abc123/edit?tab=t.second',
    });

    expect(actual).toHaveProperty('markdown', '# Second\n\n');
  });

  it('throws when the tab does not exist', async () => {
    let actual = null;
    try {
      await documentRead({
        documentId: 'https://docs.google.com/document/d/abc123/edit?tab=t.nope',
      });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GDOC_TAB_NOT_FOUND');
    expect(actual).toHaveProperty(
      'message',
      'Tab "t.nope" not found in document',
    );
  });

  it('throws when the document id is missing', async () => {
    let actual = null;
    try {
      await documentRead({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GDOC_DOCUMENT_ID_MISSING');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('returns the document, formatted', async () => {
    __.formatDocument.mockReturnValue({ id: 'formatted' });

    const actual = await documentRead({ documentId: 'abc123' });

    expect(actual).toEqual({ id: 'formatted' });
  });
});
