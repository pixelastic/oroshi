import { _ } from 'golgoth';

export let __;

const BULLET_PRESETS = {
  bullet: 'BULLET_DISC_CIRCLE_SQUARE',
  numbered: 'NUMBERED_DECIMAL_ALPHA_ROMAN',
};

/**
 * Build the batchUpdate requests that copy the content of a converted Document
 * at the end of another Document, keeping what is already there
 * @param {object} doc - Converted Document, as returned by documents.get
 * @param {number} endIndex - End index of the body of the target Document
 * @returns {object[]} The batchUpdate requests
 */
export function buildAppendRequests(doc, endIndex) {
  // The last paragraph of the target ends with a newline that cannot be
  // split: the text goes before it, after a newline that closes the last
  // paragraph. An empty Document has nothing to close
  const insertIndex = endIndex - 1;
  const isEmpty = endIndex <= 2;
  const firstIndex = isEmpty ? insertIndex : insertIndex + 1;

  const paragraphs = __.layoutParagraphs(doc, firstIndex);
  const lastEnd = _.last(paragraphs).endIndex;
  const range = { startIndex: firstIndex, endIndex: lastEnd };

  // The final newline of the text already exists in the target
  const text = _.chain(paragraphs)
    .map('text')
    .join('')
    .replace(/\n$/, '')
    .value();

  return [
    {
      insertText: {
        location: { index: insertIndex },
        text: `${isEmpty ? '' : '\n'}${text}`,
      },
    },
    // The new paragraphs inherit the bullets of the last paragraph
    { deleteParagraphBullets: { range } },
    ..._.map(paragraphs, __.paragraphStyleRequest),
    ..._.chain(paragraphs).flatMap('runs').map(__.textStyleRequest).value(),
    ...__.bulletRequests(paragraphs),
  ];
}

__ = {
  /**
   * Position the paragraphs of the converted Document in the target Document
   * @param {object} doc - Converted Document
   * @param {number} firstIndex - Index of the first inserted character
   * @returns {object[]} Paragraphs with their text, index range, style, bullet and runs
   */
  layoutParagraphs(doc, firstIndex) {
    let cursor = firstIndex;
    return _.chain(doc.body.content)
      .map('paragraph')
      .compact()
      .map((paragraph) => {
        const startIndex = cursor;
        // A nested item starts with one tab per level, that the creation of
        // the bullet removes
        const tabs = '\t'.repeat(paragraph.bullet?.nestingLevel ?? 0);
        cursor += tabs.length;

        const runs = _.chain(paragraph.elements)
          .map('textRun')
          .compact()
          .map(({ content, textStyle }) => {
            const run = {
              startIndex: cursor,
              // The newline is styled too, or it keeps the style of the
              // place where the text is inserted
              endIndex: cursor + content.length,
              textStyle,
            };
            cursor += content.length;
            return run;
          })
          .value();

        return {
          text:
            tabs +
            _.chain(paragraph.elements).map('textRun.content').join('').value(),
          startIndex,
          endIndex: cursor,
          namedStyleType: paragraph.paragraphStyle.namedStyleType,
          bulletKind: __.bulletKind(doc, paragraph.bullet),
          runs,
        };
      })
      .value();
  },
  /**
   * Tell if a bullet is a bullet or a number
   * @param {object} doc - Converted Document
   * @param {object} [bullet] - Bullet of the paragraph
   * @returns {string|undefined} bullet or numbered, undefined for no bullet
   */
  bulletKind(doc, bullet) {
    if (!bullet) {
      return undefined;
    }
    const nestingLevels = doc.lists[bullet.listId].listProperties.nestingLevels;
    const level = nestingLevels[bullet.nestingLevel ?? 0];
    return level.glyphType ? 'numbered' : 'bullet';
  },
  /**
   * Build the request that copies the style of a paragraph
   * @param {object} paragraph - Paragraph, positioned
   * @param {number} paragraph.startIndex - First index of the paragraph
   * @param {number} paragraph.endIndex - Index after the newline of the paragraph
   * @param {string} paragraph.namedStyleType - Named style, like HEADING_1
   * @returns {object} An updateParagraphStyle request
   */
  paragraphStyleRequest({ startIndex, endIndex, namedStyleType }) {
    return {
      updateParagraphStyle: {
        range: { startIndex, endIndex },
        paragraphStyle: { namedStyleType },
        fields: 'namedStyleType',
      },
    };
  },
  /**
   * Build the request that copies the style of a run. The fields that the run
   * does not set are reset, so nothing is inherited from the inserted place
   * @param {object} run - Run, positioned
   * @param {number} run.startIndex - First index of the run
   * @param {number} run.endIndex - Index after the run
   * @param {object} run.textStyle - Text style of the run in the converted Document
   * @returns {object} An updateTextStyle request
   */
  textStyleRequest({ startIndex, endIndex, textStyle }) {
    const fields = ['bold', 'italic', 'link', 'weightedFontFamily'];
    return {
      updateTextStyle: {
        range: { startIndex, endIndex },
        textStyle: _.pick(textStyle, fields),
        fields: fields.join(','),
      },
    };
  },
  /**
   * Build the requests that turn the list paragraphs into bullets. Each list
   * covers consecutive paragraphs of the same kind. The requests go from the
   * end, because each one removes the tabs of the nested items
   * @param {object[]} paragraphs - Paragraphs, positioned
   * @returns {object[]} The createParagraphBullets requests
   */
  bulletRequests(paragraphs) {
    return _.chain(paragraphs)
      .reduce((lists, { startIndex, endIndex, bulletKind }) => {
        const previous = _.last(lists);
        if (!bulletKind) {
          return [...lists, null];
        }
        if (previous?.bulletKind === bulletKind) {
          previous.endIndex = endIndex;
          return lists;
        }
        return [...lists, { startIndex, endIndex, bulletKind }];
      }, [])
      .compact()
      .reverse()
      .map(({ startIndex, endIndex, bulletKind }) => ({
        createParagraphBullets: {
          range: { startIndex, endIndex },
          bulletPreset: BULLET_PRESETS[bulletKind],
        },
      }))
      .value();
  },
};
