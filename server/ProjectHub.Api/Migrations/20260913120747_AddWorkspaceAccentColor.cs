using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ProjectHub.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddWorkspaceAccentColor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "AccentColor",
                table: "WorkSpaces",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "teal");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AccentColor",
                table: "WorkSpaces");
        }
    }
}
