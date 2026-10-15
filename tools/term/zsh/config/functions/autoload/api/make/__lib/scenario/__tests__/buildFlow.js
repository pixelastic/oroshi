import { buildFlow } from '../buildFlow.js';

describe('buildFlow', () => {
  it.each([
    {
      title: 'keeps the id and module of a flat flow in order',
      input: [
        { id: 1, module: 'gateway:CustomWebHook' },
        { id: 49, module: 'gateway:WebhookRespond' },
      ],
      expected: [
        { id: 1, module: 'gateway:CustomWebHook' },
        { id: 49, module: 'gateway:WebhookRespond' },
      ],
    },
    {
      title: 'adds the filter name to a module that has a filter',
      input: [
        { id: 1, module: 'gateway:CustomWebHook' },
        {
          id: 92,
          module: 'airtable:ActionCreateRecord',
          filter: { name: 'Throttle', conditions: [[{ a: '1', o: 'exist' }]] },
        },
      ],
      expected: [
        { id: 1, module: 'gateway:CustomWebHook' },
        { id: 92, module: 'airtable:ActionCreateRecord', filter: 'Throttle' },
      ],
    },
    {
      title:
        'nests the routes of a router, each with its filter and its own flow',
      input: [
        {
          id: 79,
          module: 'builtin:BasicRouter',
          routes: [
            {
              flow: [
                {
                  id: 80,
                  module: 'cloudconvert:ConvertFile',
                  filter: { name: 'Too big' },
                },
                { id: 129, module: 'openai-gpt-3:CreateTranscription' },
              ],
            },
            { flow: [{ id: 123, module: 'util:SetVariables' }] },
          ],
        },
      ],
      expected: [
        {
          id: 79,
          module: 'builtin:BasicRouter',
          routes: [
            {
              filter: 'Too big',
              flow: [
                {
                  id: 80,
                  module: 'cloudconvert:ConvertFile',
                  filter: 'Too big',
                },
                { id: 129, module: 'openai-gpt-3:CreateTranscription' },
              ],
            },
            {
              filter: undefined,
              flow: [{ id: 123, module: 'util:SetVariables' }],
            },
          ],
        },
      ],
    },
    {
      title: 'nests a router inside the route of another router',
      input: [
        {
          id: 79,
          module: 'builtin:BasicRouter',
          routes: [
            {
              flow: [
                {
                  id: 118,
                  module: 'builtin:BasicRouter',
                  routes: [
                    {
                      flow: [
                        {
                          id: 117,
                          module: 'markdown:Compile',
                          filter: { name: 'Doc' },
                        },
                      ],
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
      expected: [
        {
          id: 79,
          module: 'builtin:BasicRouter',
          routes: [
            {
              filter: undefined,
              flow: [
                {
                  id: 118,
                  module: 'builtin:BasicRouter',
                  routes: [
                    {
                      filter: 'Doc',
                      flow: [
                        { id: 117, module: 'markdown:Compile', filter: 'Doc' },
                      ],
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
    },
    {
      title: 'drops mapper and parameters',
      input: [
        {
          id: 1,
          module: 'util:SetVariables',
          version: 1,
          mapper: { a: 1 },
          parameters: { b: 2 },
          metadata: { designer: { x: 0 } },
        },
      ],
      expected: [{ id: 1, module: 'util:SetVariables' }],
    },
  ])('$title', ({ input, expected }) => {
    const actual = buildFlow(input);

    expect(actual).toEqual(expected);
  });
});
