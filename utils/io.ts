// ╭──────────────────────────────────────────────────────────────────────────────────╮
// │ 📌 High Order Overview                                                           │
// ┣──────────────────────────────────────────────────────────────────────────────────┫
// │ ➤ Code Format   // V.8.0                                                         │
// │ ➤ Status        // 🔒 LOCKED                                                     │
// │ ➤ Author(s)     // @migbash                                                      │
// │ ➤ Maintainer(s) // @migbash                                                      │
// │ ➤ Created on    // 2024-07-13                                                    │
// ┣──────────────────────────────────────────────────────────────────────────────────┫
// │ 📝 Description                                                                   │
// ┣──────────────────────────────────────────────────────────────────────────────────┫
// │ Betarena (Module)
// │ |: Script Deployment (BetarenaBank) Definitions
// ╰──────────────────────────────────────────────────────────────────────────────────╯

// #region ➤ 📦 Package Imports

import fs from 'fs-extra';

// #endregion ➤ 📦 Package Imports

/**
 * @author
 *  @migbash
 * @summary
 *  🟦 HELPER
 * @description
 *  📝 read from file as json.
 * @param { string } path
 *  💠 **REQUIRED**
 * @returns { Promise < T1 > }
 *  📤 data as json.
 */
export async function readFromFileAsJson
< T1 >
(
  path: string
): Promise < T1 >
{
  await fs.ensureFile(path);

  let data = [] as T1;

  try
  {
    data = await fs.readJSON(path) as T1
  }
  catch (error)
  {
    data = [] as T1;
  }

  // [🐞]
  // console.log(data);

  return data as T1;
}

/**
 * @author
 *  @migbash
 * @summary
 *  🟦 HELPER
 * @description
 *  📝 write to file.
 * @param { string } path
 *  💠 **REQUIRED**
 * @param { string } data
 *  💠 **REQUIRED**
 * @returns { void }
 */
export async function writeToFile
(
  path: string,
  data: any
): Promise < void >
{
  // ╭─────
  // │ NOTE: IMPORTANT |:| log contract deployment data.
  // ╰─────
  await fs.outputFile
  (
    path,
    JSON.stringify(data, null, 2),
    {
      flag: 'w'
    }
  );

  return;
}