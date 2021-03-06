﻿using SharpShell.Attributes;
using SharpShell.SharpContextMenu;
using Svetomech.Utilities;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace Add2Autorun
{
    /// <summary>
    /// Add any file in windows explorer to autorun.
    /// </summary>
    /// <seealso cref="SharpContextMenu" />
    [ComVisible(true)]
    [COMServerAssociation(AssociationType.AllFiles)]
    public class AddToAutorunExtension : SharpContextMenu
    {
        /// <summary>
        /// Determines whether this instance can show menu.
        /// Currently only one file can be processed at a time.
        /// </summary>
        /// <returns>
        /// <c>true</c> if this instance should show a shell context menu for the specified file list; otherwise, <c>false</c>.
        /// </returns>
        protected override bool CanShowMenu() => SelectedItemPaths?.Count() == 1;

        /// <summary>
        /// Creates the context menu.
        /// </summary>
        /// <returns>
        /// The context menu for the shell context menu.
        /// </returns>
        protected override ContextMenuStrip CreateMenu()
        {
            string filePath = Path.GetFullPath(SelectedItemPaths.Single());
            string fileName = Path.GetFileNameWithoutExtension(filePath);
            bool isAutorunAlready = App.VerifyAutorun(fileName, filePath);

            var itemAddToAutorun = new ToolStripMenuItem
            {
                Text = isAutorunAlready
                    ? Localization.Add2Autorun.RemoveFromAutorun
                    : Localization.Add2Autorun.AddToAutorun
            };
            itemAddToAutorun.Click += (sender, args)
                => App.SwitchAutorun(fileName, !isAutorunAlready ? filePath : null);

            var menu = new ContextMenuStrip();
            menu.Items.Add(itemAddToAutorun);
            return menu;
        }
    }
}
